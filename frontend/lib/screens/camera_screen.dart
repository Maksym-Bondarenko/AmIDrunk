
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/timer_provider.dart';
import '../UI/global_timer_overlay.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isProcessingBatch = false;
  bool _isLoading = false;
  String _errorMessage = "";

  // Data received from the backend
  String drunkLevel = "Unknown";
  double heartRate = 0.0;
  double hrv = 0.0;
  double eyeRedness = 0.0;

  List<CameraImage> frameBuffer = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _initializeCamera();
  }

  /// Load saved results from SharedPreferences
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      drunkLevel = prefs.getString('drunkLevel') ?? "Unknown";
      heartRate = prefs.getDouble('heartRate') ?? 0.0;
      hrv = prefs.getDouble('hrv') ?? 0.0;
      eyeRedness = prefs.getDouble('eyeRedness') ?? 0.0;
    });
  }

  /// Save the latest results to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('drunkLevel', drunkLevel);
    await prefs.setDouble('heartRate', heartRate);
    await prefs.setDouble('hrv', hrv);
    await prefs.setDouble('eyeRedness', eyeRedness);
  }

  /// Initialize the camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      _startFrameBatching();
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize camera: $e";
      });
    }
  }

  /// Start batching frames and sending them to the backend
  void _startFrameBatching() {
    _cameraController?.startImageStream((CameraImage image) {
      if (frameBuffer.length < 30) {
        frameBuffer.add(image);
      }

      if (frameBuffer.length == 30 && !_isProcessingBatch) {
        _isProcessingBatch = true;
        setState(() {
          _isLoading = true;
          _errorMessage = "";
        });

        ApiService.sendFrameBatchToBackend(frameBuffer).then((response) {
          setState(() {
            drunkLevel = response['drunk_level'] ?? drunkLevel;
            heartRate = (response['heart_rate'] ?? heartRate).toDouble();
            hrv = (response['hrv'] ?? hrv).toDouble();
            eyeRedness = (response['eye_redness'] ?? eyeRedness).toDouble();
            _isLoading = false;
          });

          _saveData(); // Save results
          frameBuffer.clear();
          _isProcessingBatch = false;
        }).catchError((error) {
          setState(() {
            _errorMessage = "Error processing frames: $error";
            _isLoading = false;
          });
          frameBuffer.clear();
          _isProcessingBatch = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showWarning = _isDrunkLevelDangerous();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Alco-Camera",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),

          // Error Message Overlay
          if (_errorMessage.isNotEmpty)
            _buildErrorOverlay(),

          // Loading Indicator Overlay
          if (_isLoading)
            _buildLoadingOverlay(),

          // Data Overlay
          _buildDataOverlay(showWarning),

          // Global Timer Overlay (ADDED)
          GlobalTimerOverlay(),
        ],
      ),
    );
  }

  /// Build an error message overlay
  Widget _buildErrorOverlay() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Build a loading overlay while processing frames
  Widget _buildLoadingOverlay() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
            ),
            SizedBox(height: 12),
            Text(
              "Processing...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the data overlay displaying results
  Widget _buildDataOverlay(bool showWarning) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.white.withOpacity(0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDataRow("Drunkenness Level", drunkLevel),
              SizedBox(height: 8),
              _buildDataRow("Heart Rate", "${heartRate.toStringAsFixed(1)} BPM"),
              SizedBox(height: 8),
              _buildDataRow("HRV", "${hrv.toStringAsFixed(1)} ms"),
              SizedBox(height: 8),
              _buildDataRow("Eye Redness", "${eyeRedness.toStringAsFixed(1)}"),
              if (showWarning) _buildWarningMessage(),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build individual data rows
  Widget _buildDataRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "$title:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepPurple),
          ),
        ),
        Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  /// Display warning message if intoxication level is too high
  Widget _buildWarningMessage() {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.redAccent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Warning: High intoxication level detected!",
                style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Determine if the drunkenness level is dangerous
  bool _isDrunkLevelDangerous() {
    if (drunkLevel == "Unknown") return false;
    double? level = double.tryParse(drunkLevel);
    return level != null && level > 0.30;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
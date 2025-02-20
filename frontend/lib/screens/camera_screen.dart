// File: camera_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/timer_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isProcessingBatch = false;

  // Data received from the backend
  String drunkLevel = "Unknown";
  double heartRate = 0.0;
  double hrv = 0.0;
  double eyeRedness = 0.0;

  // Loading and error states
  bool _isLoading = false;
  String _errorMessage = "";

  List<CameraImage> frameBuffer = []; // Buffer to store frames for a batch

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initialize the camera and start frame batching
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
            if (response['drunk_level'] != null) {
              drunkLevel = response['drunk_level'];
            }
            if (response['heart_rate'] != null) {
              heartRate = (response['heart_rate']).toDouble();
            }
            if (response['hrv'] != null) {
              hrv = (response['hrv']).toDouble();
            }
            if (response['eye_redness'] != null) {
              eyeRedness = (response['eye_redness']).toDouble();
            }
            _isLoading = false;
          });
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
    final timerProvider = Provider.of<TimerProvider>(context);
    bool showWarning = _isDrunkLevelDangerous();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Alco-Camera",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            Center(
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
            ),
          // Loading Indicator Overlay
          if (_isLoading)
            Center(
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
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Processing...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Data Overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
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
                    if (showWarning) ...[
                      SizedBox(height: 12),
                      Container(
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
                                "Warning: This level of intoxication is extremely dangerous!",
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Determine if the drunkenness level is dangerous
  bool _isDrunkLevelDangerous() {
    if (drunkLevel == "Unknown") return false;
    double? level = double.tryParse(drunkLevel);
    if (level == null) return false;
    return level > 0.30; // Adjust threshold as needed
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

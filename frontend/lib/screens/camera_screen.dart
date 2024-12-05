import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/api_service.dart';

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

  List<CameraImage> frameBuffer = []; // Buffer to store frames for a batch

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);

    await _cameraController!.initialize();
    _startFrameBatching();
    setState(() {});
  }

  void _startFrameBatching() {
    _cameraController?.startImageStream((CameraImage image) {
      if (frameBuffer.length < 30) {
        frameBuffer.add(image);
      }

      if (frameBuffer.length == 30 && !_isProcessingBatch) {
        _isProcessingBatch = true;
        ApiService.sendFrameBatchToBackend(frameBuffer).then((response) {
          setState(() {
            drunkLevel = response['drunk_level'] ?? "Unknown";
            heartRate = (response['heart_rate'] ?? 0.0).toDouble();
            hrv = (response['hrv'] ?? 0.0).toDouble();
            eyeRedness = (response['eye_redness'] ?? 0.0).toDouble();
          });
          frameBuffer.clear();
          _isProcessingBatch = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alco-Camera")),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverlayText("Drunkenness Level: $drunkLevel"),
                _buildOverlayText("Heart Rate: ${heartRate.toStringAsFixed(1)} BPM"),
                _buildOverlayText("HRV: ${hrv.toStringAsFixed(1)} ms"),
                _buildOverlayText("Eye Redness: ${eyeRedness.toStringAsFixed(1)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayText(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

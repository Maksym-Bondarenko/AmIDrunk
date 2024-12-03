import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  String _drunkLevel = "Unknown";
  int _heartRate = 0;
  int _hrv = 0;
  double _eyeRedness = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    _startFrameCapture();
  }

  void _startFrameCapture() {
    _cameraController?.startImageStream((CameraImage image) async {
      if (_isProcessing) return;

      _isProcessing = true;

      try {
        // Convert the image to bytes and send to backend
        final results = await _sendFrameToBackend(image);
        setState(() {
          _heartRate = results['heart_rate'];
          _hrv = results['hrv'];
          _eyeRedness = results['eye_redness'];
          _drunkLevel = results['drunk_level'];
        });
      } catch (e) {
        print("Error processing frame: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<Map<String, dynamic>> _sendFrameToBackend(CameraImage image) async {
    // Convert CameraImage to bytes
    final bytes = image.planes[0].bytes;

    // Send frame to backend
    final request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/process_frame/'));
    request.files.add(http.MultipartFile.fromBytes('frame', bytes, filename: 'frame.jpg'));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drunkenness Level Estimator")),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          SizedBox(height: 20),
          Text("Drunkenness Level: $_drunkLevel"),
          Text("Heart Rate: $_heartRate BPM"),
          Text("HRV: $_hrv ms"),
          Text("Eye Redness: $_eyeRedness"),
        ],
      ),
    );
  }
}

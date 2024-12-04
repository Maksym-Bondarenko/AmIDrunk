import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  bool _isProcessingBatch = false;

  // Data received from the backend
  String drunkLevel = "Unknown";
  double heartRate = 0.0;
  double hrv = 0.0;
  double eyeRedness = 0.0;

  List<CameraImage> frameBuffer = []; // Buffer to store frames for a batch
  int receivedBatches = 0; // Counter to track received batches

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get available cameras
    final cameras = await availableCameras();

    // Select the front camera
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Initialize the selected camera
    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);

    // Initialize the camera and start the stream
    await _cameraController!.initialize();

    // Start streaming frames for processing
    _startFrameBatching();
    setState(() {});
  }

  void _startFrameBatching() {
    _cameraController?.startImageStream((CameraImage image) {
      // Add frames to the buffer
      if (frameBuffer.length < 30) {
        frameBuffer.add(image);
      }

      // Process batch once 30 frames are collected
      if (frameBuffer.length == 30 && !_isProcessingBatch) {
        _isProcessingBatch = true;
        _sendFrameBatchToBackend(frameBuffer).then((_) {
          frameBuffer.clear();
          _isProcessingBatch = false;
        });
      }
    });
  }

  Future<void> _sendFrameBatchToBackend(List<CameraImage> batch) async {
    try {
      final int width = batch[0].width;
      final int height = batch[0].height;

      // Serialize the batch of frames
      List<Map<String, dynamic>> serializedFrames = batch.map((image) {
        return {
          'width': image.width,
          'height': image.height,
          'y_plane': base64Encode(image.planes[0].bytes),
          'u_plane': base64Encode(_extractPlane(image.planes[1], image.width ~/ 2, image.height ~/ 2,
              image.planes[1].bytesPerRow, image.planes[1].bytesPerPixel!)),
          'v_plane': base64Encode(_extractPlane(image.planes[2], image.width ~/ 2, image.height ~/ 2,
              image.planes[2].bytesPerRow, image.planes[2].bytesPerPixel!)),
        };
      }).toList();

      // Send the serialized batch to the backend
      final response = await http.post(
        Uri.parse('http://192.168.1.223:8000/process_batch/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'frames': serializedFrames}),
      );

      if (response.statusCode == 200) {
        final parsedResponse = jsonDecode(response.body);

        if (parsedResponse['status'] == "Waiting for more frames") {
          // Accumulate batches
          receivedBatches++;
          print("Waiting: Batches received: $receivedBatches");
        } else {
          // Update metrics once 10 batches are processed
          setState(() {
            heartRate = (parsedResponse['heart_rate'] ?? 0.0).toDouble();
            hrv = (parsedResponse['hrv'] ?? 0.0).toDouble();
            eyeRedness = (parsedResponse['eye_redness'] ?? 0.0).toDouble();
            drunkLevel = parsedResponse['drunk_level'] ?? "Unknown";
          });

          // Reset batch counter
          receivedBatches = 0;
          print("Metrics updated: HR: $heartRate, HRV: $hrv, Redness: $eyeRedness");
        }
      } else {
        print("Failed to send batch: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending batch: $e");
    }
  }

  Uint8List _extractPlane(Plane plane, int width, int height, int rowStride, int pixelStride) {
    final Uint8List extracted = Uint8List(width * height);
    int index = 0;

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final pixelIndex = row * rowStride + col * pixelStride;
        extracted[index++] = plane.bytes[pixelIndex];
      }
    }

    return extracted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drunkenness Estimation")),
      body: Stack(
        children: [
          // Display the camera preview
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),

          // Overlay for displaying live data
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

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class ApiService {
  static Future<Map<String, dynamic>> sendFrameBatchToBackend(List<CameraImage> batch) async {
    try {
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

      final response = await http.post(
//       Uri.parse('http://192.168.1.223:8000/process_batch/'),
        Uri.parse('http://10.5.3.79:8000/process_batch/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'frames': serializedFrames}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to send batch: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending batch: $e");
      return {"error": e.toString()};
    }
  }

  static Uint8List _extractPlane(Plane plane, int width, int height, int rowStride, int pixelStride) {
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
}

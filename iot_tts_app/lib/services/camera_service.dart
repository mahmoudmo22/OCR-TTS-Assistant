import 'package:camera/camera.dart';

class CameraService {
  Future<CameraController> initializeController() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    return controller;
  }
}

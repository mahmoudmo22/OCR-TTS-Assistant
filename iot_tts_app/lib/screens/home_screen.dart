import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/camera_service.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _cameraService = CameraService();
  CameraController? _controller;
  Future<void>? _cameraFuture;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _permissionDenied = true;
      });
      return;
    }

    final controller = await _cameraService.initializeController();
    setState(() {
      _controller = controller;
      _cameraFuture = controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess(AppProvider provider) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (_controller!.value.isTakingPicture) {
      return;
    }

    final image = await _controller!.takePicture();
    final text = await provider.recognizeText(image.path);

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          imagePath: image.path,
          extractedText: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image-to-Speech'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _permissionDenied
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Camera permission is required to capture images.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: openAppSettings,
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              ),
            )
          : FutureBuilder<void>(
              future: _cameraFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller == null || !_controller!.value.isInitialized) {
                  return const Center(
                    child: Text('Camera is not available.'),
                  );
                }

                return Stack(
                  children: [
                    CameraPreview(_controller!),
                    if (provider.isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isProcessing
            ? null
            : () => _captureAndProcess(provider),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(CameraApp(cameras: cameras));
}

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraApp({super.key, required this.cameras});

  @override
  // ignore: library_private_types_in_public_api
  _CameraAppState createState() => _CameraAppState();
}


class _CameraAppState extends State<CameraApp> {
  CameraController? _controller;
  XFile? _lastImage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras.first, ResolutionPreset.medium);
      _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isInitialized = true);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null) return;
    try {
      final XFile file = await _controller!.takePicture();
      setState(() => _lastImage = file);
      debugPrint('Saved to ${file.path}');
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera Demo')),
        body: _isInitialized && _controller != null
            ? Stack(
                children: [
                  CameraPreview(_controller!),
                  if (_lastImage != null)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Image.file(File(_lastImage!.path), fit: BoxFit.cover),
                      ),
                    ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
        floatingActionButton: _isInitialized
            ? FloatingActionButton(
                onPressed: _takePicture,
                child: const Icon(Icons.camera_alt),
              )
            : null,
      ),
    );
  }
}

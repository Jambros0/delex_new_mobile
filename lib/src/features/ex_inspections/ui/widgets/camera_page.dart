import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for screen orientation

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isFlashOn = false;
  XFile? _capturedFile;
  int selectedCameraIndex = 1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]).then((_) {
      _initCamera(0);
    });
  }

  Future<void> _initCamera([int cameraIndex = 0]) async {
    _cameras = await availableCameras();
    selectedCameraIndex = cameraIndex;
    _controller = CameraController(
      _cameras[selectedCameraIndex],
      ResolutionPreset.max,
    );
    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      if (e.code == 'AudioAccessDenied') {
        _controller = CameraController(
          _cameras[selectedCameraIndex],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _controller!.initialize();
      } else {
        rethrow;
      }
    }
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return; // No other camera
    selectedCameraIndex = (selectedCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    await _initCamera(selectedCameraIndex);
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null) {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedFile = image;
      });
    }
  }

  void _retake() {
    setState(() {
      _capturedFile = null;
    });
  }

  void _useImage() {
    if (_capturedFile != null) {
      Navigator.pop(context, File(_capturedFile!.path));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]); // Maintain landscape orientation
    super.dispose();
  }

  // int _calculateQuarterTurns() {
  //   final orientation = MediaQuery.of(context).orientation;
  //   final isBackCamera =
  //       _cameras[selectedCameraIndex].lensDirection == CameraLensDirection.back;
  //   if (orientation == Orientation.landscape) {
  //     // return isBackCamera ? 1 : 1;
  //     return 0;
  //   } else {
  //     return isBackCamera ? 1 : 3;
  //   }
  // }
  int _calculateQuarterTurns() {
    final camera = _cameras[selectedCameraIndex];
    final orientation = _controller?.value.deviceOrientation;

    if (orientation == null) return 0;

    switch (orientation) {
      case DeviceOrientation.landscapeLeft:
        return camera.lensDirection == CameraLensDirection.front ? 1 : 1;
      case DeviceOrientation.landscapeRight:
        return camera.lensDirection == CameraLensDirection.front ? 3 : 3;
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.portraitDown:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              _capturedFile == null
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: (selectedCameraIndex == 0)
                            ? Matrix4.identity()
                            : Matrix4.rotationY(pi),
                        child: RotatedBox(
                          quarterTurns:
                              _calculateQuarterTurns(), // Handle rotation
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: (selectedCameraIndex == 0)
                            ? Matrix4.identity()
                            : Matrix4.rotationY(pi),
                        child: Image.file(
                          File(_capturedFile!.path),
                          width: double.maxFinite,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
              if (_capturedFile == null) ...[
                Positioned(
                  top: 40,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: _toggleFlash,
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: _switchCamera,
                        child: const Icon(Icons.switch_camera, size: 28),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width / 2 - 222,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _captureImage,
                    child: const Icon(Icons.camera_alt, size: 28),
                  ),
                ),
              ] else ...[
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: _retake,
                        child: const Icon(Icons.refresh, size: 30),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: _useImage,
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

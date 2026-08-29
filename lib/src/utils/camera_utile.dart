// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';

// class CameraPage extends StatefulWidget {
//   @override
//   _CameraPageState createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   CameraController? _controller;
//   List<CameraDescription>? cameras;
//   String? imagePath;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   // Initialize the camera
//   Future<void> _initializeCamera() async {
//     cameras = await availableCameras();
//     _controller = CameraController(cameras![0], ResolutionPreset.high);

//     await _controller?.initialize();

//     setState(() {});
//   }

//   // Capture and process image
//   Future<void> _captureImage() async {
//     if (_controller!.value.isInitialized) {
//       // Capture the image
//       final XFile file = await _controller!.takePicture();

//       // Process the image to fix orientation
//       final processedFile = await _processImage(file);

//       setState(() {
//         imagePath = processedFile.path;
//       });
//     }
//   }

//   // Process image to fix orientation (landscape/portrait)
//   Future<File> _processImage(XFile pickedImage) async {
//     final imageBytes = await pickedImage.readAsBytes();
//     final decodedImage = img.decodeImage(imageBytes);

//     if (decodedImage != null) {
//       // Fix the orientation (if any) using EXIF data
//       final orientedImage = img.bakeOrientation(decodedImage);

//       // Encode the fixed image to bytes
//       final fixedBytes = img.encodeJpg(orientedImage);

//       // Save the fixed image to a temporary file
//       final tempDir = await getTemporaryDirectory();
//       final file = await File('${tempDir.path}/fixed_image.jpg')
//           .writeAsBytes(fixedBytes);

//       return file;
//     } else {
//       throw Exception("Failed to decode image");
//     }
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Camera')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text('Camera')),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Camera preview
//           Expanded(child: CameraPreview(_controller!)),

//           // Capture button
//           ElevatedButton(
//             onPressed: _captureImage,
//             child: Text('Capture Image'),
//           ),

//           // Display the captured image after processing
//           if (imagePath != null) Image.file(File(imagePath!)),
//         ],
//       ),
//     );
//   }
// }

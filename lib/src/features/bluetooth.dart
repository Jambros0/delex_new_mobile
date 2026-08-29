// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// class RFIDScannerPage extends StatefulWidget {
//   @override
//   _RFIDScannerPageState createState() => _RFIDScannerPageState();
// }

// class _RFIDScannerPageState extends State<RFIDScannerPage> {
//   final FlutterBluePlus flutterBlue = FlutterBluePlus();
//   BluetoothDevice? connectedDevice;
//   String scannedData = "Waiting for scan...";
//   bool isConnected = false;

//   Future<void> requestPermissions() async {
//     await Permission.bluetoothScan.request();
//     await Permission.bluetoothConnect.request();
//     await Permission.location.request();
//   }

//   @override
//   void initState() {
//     super.initState();
//     startScan();
//   }

//   void startScan() async {
//     await requestPermissions();
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 2));

//     FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         // Signal strength
//         if (result.device.name.contains("IS-MP.1")) { // Adjust for your device name

//           FlutterBluePlus.stopScan();
//           connectToDevice(result.device);
//           break;
//         }
//       }
//     });
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       connectedDevice = device;
//       isConnected = true;

//       discoverAndListen(device);
//     } catch (e) {
//     }
//   }

//   Future<void> discoverAndListen(BluetoothDevice device) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         if (characteristic.properties.notify) {
//           await characteristic.setNotifyValue(true);
//           characteristic.lastValueStream.listen((value) {
//             setState(() {
//               scannedData = String.fromCharCodes(value);
//             });
//           });
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("RFID/NFC Scanner")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Scanned Data:",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               scannedData,
//               style: TextStyle(fontSize: 18, color: Colors.blue),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

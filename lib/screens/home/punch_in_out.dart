// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
//
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hrms/Constants.dart';
// import 'package:hrms/common_widgets/common_styles.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'HomeScreen.dart';
// /*
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Employee Management App")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (context) => const PunchInDialog(isPunchIn: true),
//             );
//           },
//           child: const Text("Punch-In"),
//         ),
//       ),
//     );
//   }
// } */
//
// class PunchInDialog extends StatefulWidget {
//   final bool isPunchIn;
//
//   const PunchInDialog({Key? key, required this.isPunchIn}) : super(key: key);
//
//   @override
//   _PunchInDialogState createState() => _PunchInDialogState();
// }
//
// class _PunchInDialogState extends State<PunchInDialog> {
//   Position? _currentPosition;
//   GoogleMapController? _mapController;
//
//   String _latitude = "Fetching...";
//   String _longitude = "Fetching...";
//   String _address = "Fetching address...";
//   String _time = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//
//     // Check for location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied.');
//     }
//
//     // Get the current position
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//
//     Placemark place = placemarks.first;
//     String currentTime =
//         DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//
//     // Check if the widget is still mounted before calling setState
//     if (!mounted) return;
//
//     setState(() {
//       _currentPosition = position;
//       _latitude = position.latitude.toString();
//       _longitude = position.longitude.toString();
//       _address =
//           "${place.thoroughfare} ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
//       _time = currentTime;
//     });
//
//     // Move the map camera to the user's location
//     if (_mapController != null) {
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLng(
//           LatLng(position.latitude, position.longitude),
//         ),
//       );
//     }
//   }
//
//   Future<void> _captureAndProcessImage() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final ImagePicker picker = ImagePicker();
//       final XFile? pickedFile =
//           await picker.pickImage(source: ImageSource.camera);
//
//       if (pickedFile == null) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No image captured!")),
//         );
//         return;
//       }
//
//       // Get location and time
//       await _getCurrentLocation();
//
//       // Read captured image
//       final File imageFile = File(pickedFile.path);
//       final ui.Image capturedImage =
//           await decodeImageFromList(await imageFile.readAsBytes());
//
//       // Create canvas for editing image
//       ui.PictureRecorder recorder = ui.PictureRecorder();
//       Canvas canvas = Canvas(recorder);
//       canvas.drawImage(capturedImage, Offset.zero, Paint());
//
//       // Define text style
//       double textStyleHeight = capturedImage.height * 0.09;
//       TextStyle textStyle = TextStyle(
//         color: Colors.white,
//         fontSize: textStyleHeight * 0.16,
//         fontWeight: FontWeight.bold,
//         shadows: const [
//           Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
//         ],
//       );
//
//       // Prepare text content
//       String textContent =
//           "Time: $_time\nLocation: $_latitude, $_longitude\n$_address";
//
//       // Measure text height dynamically
//       TextPainter textPainter = TextPainter(
//         text: TextSpan(text: textContent, style: textStyle),
//         textDirection: ui.TextDirection.ltr,
//         textAlign: TextAlign.left,
//       );
//
//       textPainter.layout(maxWidth: capturedImage.width.toDouble() - 20);
//
//       double textBoxHeight = textPainter.height + 20;
//
//       // Draw text box (background rectangle)
//       Paint rectPaint = Paint()..color = Colors.black.withOpacity(0.7);
//       canvas.drawRect(
//         Rect.fromLTWH(0, capturedImage.height - textBoxHeight,
//             capturedImage.width.toDouble(), textBoxHeight),
//         rectPaint,
//       );
//
//       // Draw text on the canvas
//       textPainter.paint(
//           canvas, Offset(20, capturedImage.height - textBoxHeight + 10));
//
//       // Convert canvas to image
//       ui.Image finalImage = await recorder
//           .endRecording()
//           .toImage(capturedImage.width, capturedImage.height);
//       ByteData? byteData =
//           await finalImage.toByteData(format: ui.ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();
//       // Save the processed image
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/hrms_emp.png';
//       File file = File(filePath);
//       print('_captureAndProcessImage: ${file.path}');
//       await file.writeAsBytes(pngBytes);
//       widget.isPunchIn
//           ? prefs.setBool(Constants.isPunchIn, true)
//           : prefs.setBool(Constants.isPunchIn, false);
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//
//       /* if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Image saved successfully at: $filePath")),
//       ); */
//     } catch (e) {
//       print('_captureAndProcessImage: catch');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     String currentTime = DateFormat('HH:mm').format(DateTime.now());
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             right: 0,
//             child: IconButton(
//               icon: const Icon(Icons.close, size: 20),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ),
//           Container(
//             height: 350, // Adjust height to match the design
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   widget.isPunchIn ? "Punch In" : "Punch Out",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//                 // Map view
//                 Expanded(
//                   child: _currentPosition == null
//                       ? const Center(child: CircularProgressIndicator())
//                       : ClipRRect(
//                           borderRadius: BorderRadius.circular(6.0),
//                           child: GoogleMap(
//                             initialCameraPosition: CameraPosition(
//                               target: LatLng(
//                                 _currentPosition!.latitude,
//                                 _currentPosition!.longitude,
//                               ),
//                               zoom: 15,
//                             ),
//                             markers: {
//                               Marker(
//                                 markerId: const MarkerId('current_location'),
//                                 position: LatLng(
//                                   _currentPosition!.latitude,
//                                   _currentPosition!.longitude,
//                                 ),
//                               ),
//                             },
//                             onMapCreated: (GoogleMapController controller) {
//                               _mapController = controller;
//                             },
//                             myLocationEnabled: true,
//                             myLocationButtonEnabled: false,
//                             zoomControlsEnabled: false,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(height: 10),
//                 // Sample text
//                 Text(
//                   widget.isPunchIn
//                       ? "It's time for another great day!"
//                       : 'Time to go home!',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 5),
//                 // Current time with pencil icon
//                 Text(
//                   currentTime,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 // Submit button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       _captureAndProcessImage();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: CommonStyles.primaryColor,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     ),
//                     child: Text(
//                       widget.isPunchIn ? 'Capture Image' : 'Punch Out',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

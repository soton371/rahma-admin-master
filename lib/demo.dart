// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
//
// class DemoScreen extends StatefulWidget {
//   const DemoScreen({Key? key}) : super(key: key);
//
//   @override
//   _DemoScreenState createState() => _DemoScreenState();
// }
//
// class _DemoScreenState extends State<DemoScreen> {
//
//   UploadTask? task;
//   File? file;
//
//   @override
//   Widget build(BuildContext context) {
//
//     final fileName = file != null ? file!.path : 'No File Selected';
//     //final fileName = file != null ? basename(file!.path) : 'No File Selected';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('demo'),
//         centerTitle: true,
//       ),
//       body: Container(
//         padding: EdgeInsets.all(32),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ButtonWidget(
//                 text: 'Select File',
//                 icon: Icons.attach_file,
//                 onClicked: selectFile,
//               ),
//               SizedBox(height: 8),
//               Text(
//                 fileName,
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               SizedBox(height: 48),
//               ButtonWidget(
//                 text: 'Upload File',
//                 icon: Icons.cloud_upload_outlined,
//                 onClicked: uploadFile,
//               ),
//               SizedBox(height: 20),
//               task != null ? buildUploadStatus(task!) : Container(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future selectFile() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: false);
//
//     if (result == null) return;
//     final path = result.files.single.path!;
//
//     setState(() => file = File(path));
//   }
//
//   Future uploadFile() async {
//     if (file == null) return;
//
//     final fileName = file!.path;
//     final destination = 'files/$fileName';
//
//     task = FirebaseApi.uploadFile(destination, file!);
//     setState(() {});
//
//     if (task == null) return;
//
//     final snapshot = await task!.whenComplete(() {});
//     final urlDownload = await snapshot.ref.getDownloadURL();
//
//     print('Download-Link: $urlDownload');
//   }
//
//   Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
//     stream: task.snapshotEvents,
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         final snap = snapshot.data!;
//         final progress = snap.bytesTransferred / snap.totalBytes;
//         final percentage = (progress * 100).toStringAsFixed(2);
//
//         return Text(
//           '$percentage %',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         );
//       } else {
//         return Container();
//       }
//     },
//   );
//
// }
// //for button widget
// class ButtonWidget extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final VoidCallback onClicked;
//
//   const ButtonWidget({
//     Key? key,
//     required this.icon,
//     required this.text,
//     required this.onClicked,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) => ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       primary: Color.fromRGBO(29, 194, 95, 1),
//       minimumSize: Size.fromHeight(50),
//     ),
//     child: buildContent(),
//     onPressed: onClicked,
//   );
//
//   Widget buildContent() => Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(icon, size: 28),
//       SizedBox(width: 16),
//       Text(
//         text,
//         style: TextStyle(fontSize: 22, color: Colors.white),
//       ),
//     ],
//   );
// }
//
//
// class FirebaseApi {
//   static UploadTask? uploadFile(String destination, File file) {
//     try {
//       final ref = FirebaseStorage.instance.ref(destination);
//
//       return ref.putFile(file);
//     } on FirebaseException catch (e) {
//       return null;
//     }
//   }
//
//   // static UploadTask? uploadBytes(String destination, Uint8List data) {
//   //   try {
//   //     final ref = FirebaseStorage.instance.ref(destination);
//   //
//   //     return ref.putData(data);
//   //   } on FirebaseException catch (e) {
//   //     return null;
//   //   }
//   // }
// }
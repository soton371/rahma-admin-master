import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/configs/my_sizes.dart';

class MadrasaAtimkhanaEditScreen extends StatefulWidget {
  // const MadrasaAtimkhanaEditScreen({Key? key}) : super(key: key);
  String? name, address, contact, website, details, docId, imgUrl;
  MadrasaAtimkhanaEditScreen(
      {required this.imgUrl,
      required this.name,
      required this.details,
      required this.website,
      required this.address,
      required this.contact,
      required this.docId});

  @override
  _MadrasaAtimkhanaEditScreenState createState() =>
      _MadrasaAtimkhanaEditScreenState();
}

class _MadrasaAtimkhanaEditScreenState
    extends State<MadrasaAtimkhanaEditScreen> {
  String? newName, newAddress, newContact, newWebsite, newDetails, newImgUrl;
  TextEditingController? newNameCon,
      newAddressCon,
      newContactCon,
      newWebsiteCon,
      newDetailsCon;

  //Image Get+Save from Camera
  UploadTask? task;
  File? _image;
  Future cameraImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //Image Get+Save from Gallery
  Future galleryImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  //for upload status
  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final percentage = (progress * 100).toStringAsFixed(2);

        return Text(
          'Uploading: $percentage %',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
        );
      } else {
        return Container();
      }
    },
  );

  //for internet
  bool status = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  void checkRealtimeConnection() {
    _streamSubscription = _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile) {
        status = true;
      } else if (event == ConnectivityResult.wifi) {
        setState(() {
          status = true;
        });

      } else {
        status = false;
      }
      setState(() {});
    });
  }



  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Widget noInternet(){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/json_files/9293-not-signal-no-internet-access-and-connection-lost-placeholder.json',height: 200),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No internet connection found.\nCheck your connection and try again.',
                style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 1
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkRealtimeConnection();
    newName = widget.name;
    newAddress = widget.address;
    newContact = widget.contact;
    newWebsite = widget.website;
    newDetails = widget.details;
    newImgUrl = widget.imgUrl;

    newNameCon = TextEditingController(text: newName);
    newAddressCon = TextEditingController(text: newAddress);
    newContactCon = TextEditingController(text: newContact);
    newWebsiteCon = TextEditingController(text: newWebsite);
    newDetailsCon = TextEditingController(text: newDetails);
  }

  @override
  Widget build(BuildContext context) {
    return status ? Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.background,
        elevation: 0.5,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined,color: MyColors.text,)
        ),
        title: Text('সম্পাদনা',style: TextStyle(
            color: MyColors.text
        )),
        centerTitle: true,
        actions: [
          //for delete
          IconButton(
              onPressed: () {
                final dataDelete = FirebaseFirestore.instance
                    .collection("madrasaOrphanage")
                    .doc(widget.docId.toString());
                dataDelete.delete();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete), color: MyColors.delete,),
          //for update
          IconButton(
            onPressed: () async {

              if(newImgUrl != null){
                final dataUpdate = FirebaseFirestore.instance
                    .collection("madrasaOrphanage")
                    .doc(widget.docId.toString());
                dataUpdate.update({
                  'address': newAddress,
                  'contact_no': newContact,
                  'details': newDetails,
                  'name': newName,
                  'website': newWebsite,
                  'image': newImgUrl
                });
                Navigator.pop(context);
              }else{
                var storageImage =
                FirebaseStorage.instance.ref().child(_image!.path);
                setState(() {
                  task = storageImage.putFile(_image!);
                });
                // UploadTask task = storageImage.putFile(_image!);
                newImgUrl = await (await task)!.ref.getDownloadURL();

                final dataUpdate = FirebaseFirestore.instance
                    .collection("madrasaOrphanage")
                    .doc(widget.docId.toString());
                dataUpdate.update({
                  'address': newAddress,
                  'contact_no': newContact,
                  'details': newDetails,
                  'name': newName,
                  'website': newWebsite,
                  'image': newImgUrl
                });
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.done, color: MyColors.primary,),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(MySizes.paddingBody),
        children: [
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFFffffff),
              border: Border.all(width: 2, color: const Color(0xFFffffff)),
              borderRadius: BorderRadius.circular(0),
            ),
            child: _image != null || newImgUrl != null
                ? Stack(children: [
                    Center(
                        child: newImgUrl != null
                            ? Image.network(newImgUrl.toString())
                            : Image.file(
                                _image!,
                              )),
                    Positioned(
                        right: -2,
                        top: -9,
                        child: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.black.withOpacity(0.5),
                              size: 18,
                            ),
                            onPressed: () => setState(() {
                                  newImgUrl = null;
                                  _image = null;
                                })))
                  ])
                : Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 50),
                    child: Column(
                      children: [
                        const Text('Select Your Image'),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FloatingActionButton(
                              backgroundColor: Colors.white,
                              onPressed: () {
                                cameraImage();
                              },
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Color(0xFFe37c22),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            FloatingActionButton(
                              backgroundColor: Colors.white,
                              onPressed: () {
                                galleryImage();
                              },
                              child: const Icon(Icons.photo_library_outlined,
                                  color: Color(0xFFe37c22)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          task != null ? buildUploadStatus(task!) : const SizedBox(),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: newNameCon,
            onChanged: (v) {
              newName = v;
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'প্রতিষ্ঠানের নাম'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: newAddressCon,
            onChanged: (v) {
              newAddress = v;
            },
            maxLines: 2,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'ঠিকানা'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: newContactCon,
            onChanged: (v) {
              newContact = v;
            },
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'যোগাযোগের নম্বর'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: newWebsiteCon,
            onChanged: (v) {
              newWebsite = v;
            },
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'ওয়েবসাইট'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: newDetailsCon,
            onChanged: (v) {
              newDetails = v;
            },
            maxLines: 3,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'বিস্তারিত'),
          ),
        ],
      ),
    ):noInternet();
  }
}

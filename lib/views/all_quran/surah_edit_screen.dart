import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/configs/my_sizes.dart';

class SurahEditScreen extends StatefulWidget {
  // const SurahEditScreen({Key? key}) : super(key: key);

  int? surahId;
  int? ayatId;
  String? receivedPronounce;
  String? ayatArabic;
  String? audioUrl;

  SurahEditScreen({this.ayatId,this.surahId,this.receivedPronounce,this.ayatArabic, this.audioUrl});

  @override
  State<SurahEditScreen> createState() => _SurahEditScreenState();
}

class _SurahEditScreenState extends State<SurahEditScreen> {

  String? pronounce;
  var pronounceController;

  var file;
  var fileUrl;

  // String shortFileName(){
  //   var str = fileUrl;
  //   var parts = str.split('token');
  //   var newData = parts[1].split('-');
  //   return newData[4];
  // }

  //for no internet
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
  void initState() {
    // TODO: implement initState
    super.initState();
    pronounce = widget.receivedPronounce;
    fileUrl = widget.audioUrl;
    pronounceController = TextEditingController(text: pronounce);
    checkRealtimeConnection();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  //for upload status
  UploadTask? task;
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
  Widget build(BuildContext context) {
    return status? Scaffold(
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
        ),),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async{
                if(file != null){
                  var storageFile = FirebaseStorage.instance.ref().child(file.path);
                  setState(() {
                    task = storageFile.putFile(File(file.path.toString()));
                  });

                  // UploadTask  task = storageFile.putFile(File(file.path.toString()));
                  fileUrl = await (await task)!.ref.getDownloadURL();
                  final updatePronounce = FirebaseFirestore.instance.collection('alQuran').doc('${widget.surahId! - 1}').collection('details').doc('${widget.ayatId! - 1}');
                  updatePronounce.update({
                    'pronounce': pronounce,
                    'audio': fileUrl
                  });
                  Navigator.pop(context);
                }else{
                  final updatePronounce = FirebaseFirestore.instance.collection('alQuran').doc('${widget.surahId! - 1}').collection('details').doc('${widget.ayatId! - 1}');
                  updatePronounce.update({
                    'pronounce': pronounce,
                    'audio': fileUrl
                  });
                  Navigator.pop(context);
                }

              },
              icon: Icon(Icons.done,color: MyColors.primary,)
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(MySizes.paddingBody),
        children: [
          Text(widget.ayatArabic??'not available',
          style: const TextStyle(
            fontSize: 30
          ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 20,),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'উচ্চারণ লিখুন',
              border: OutlineInputBorder(),
            ),
            controller: pronounceController,
            onChanged: (v){
              setState(() {
                pronounce = v;
              });
            },
          ),
        const SizedBox(height: 20,),
        //  audio file pic
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            //height:file != null || fileUrl != null? 50:120,
            decoration: BoxDecoration(
              color: const Color(0xFFffffff),
              border: Border.all(
                  color: MyColors.border
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: file != null || fileUrl != null ? Stack(
                children:[
                  Center(child:fileUrl != null ? Text('uploaded_ayat_no_${widget.ayatId.toString()}.mp3',style: const TextStyle(
                    fontSize: 16,
                  ),): Text('${file.name.toString()}.mp3',style: const TextStyle(
                      fontSize: 16
                  ),)),
                  Positioned(
                      right: -2,
                      top: -16,
                      child: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.black.withOpacity(0.5),
                            size: 18,
                          ),
                          onPressed: () => setState(() {
                            file = null;
                            fileUrl = null;
                          })))
                ]) :
            Column(
              children: [
                const Text('Select Your Audio File',),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async{
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if(result==null) return;
                        setState(() {
                          file = result.files.first;
                        });

                      },
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFFe37c22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          task != null ? buildUploadStatus(task!) : const SizedBox(),
        ],
      ),
    ):noInternet();
  }
}

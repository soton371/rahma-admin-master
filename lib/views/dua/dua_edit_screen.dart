import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/configs/my_sizes.dart';

class DuaEditScreen extends StatefulWidget {
  //const DuaEditScreen({Key? key}) : super(key: key);

  String? docId,arabic,bengali,pronounce,title;
  DuaEditScreen({required this.arabic, required this.docId, required this.title, required this.pronounce, required this.bengali});

  @override
  _DuaEditScreenState createState() => _DuaEditScreenState();
}

class _DuaEditScreenState extends State<DuaEditScreen> {

  String? newArabic,newBengali,newPronounce,newTitle;
  TextEditingController? newArabicCon,newBengaliCon,newPronounceCon,newTitleCon;

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
    newArabic = widget.arabic;
    newBengali = widget.bengali;
    newPronounce = widget.pronounce;
    newTitle = widget.title;
    newArabicCon = TextEditingController(text: newArabic);
    newBengaliCon = TextEditingController(text: newBengali);
    newPronounceCon = TextEditingController(text: newPronounce);
    newTitleCon = TextEditingController(text: newTitle);
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
        )),
        centerTitle: true,
        actions: [
          //for delete
          IconButton(
              onPressed: () {
                final dataDelete = FirebaseFirestore.instance
                    .collection("Dua's")
                    .doc(widget.docId.toString());
                dataDelete.delete();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),color: MyColors.delete,),
          //for update
          IconButton(
            onPressed: () {
              final dataUpdate = FirebaseFirestore.instance
                  .collection("Dua's")
                  .doc(widget.docId.toString());
              dataUpdate.update({'title': newTitle,'arabic': newArabic,'pronounce':newPronounce,'bengali':newBengali});
              Navigator.pop(context);
            },
            icon: Icon(Icons.done,color: MyColors.primary,),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(MySizes.paddingBody),
        children: [
          SizedBox(height: 20,),
          TextField(
            controller: newTitleCon,
            onChanged: (v)=>newTitle=v,
            maxLines: 5,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'শিরোনাম'
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: newArabicCon,
            onChanged: (v)=>newArabic=v,
            maxLines: 5,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'আরবি'
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: newPronounceCon,
            onChanged: (v)=>newPronounce=v,
            maxLines: 5,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'উচ্চারণ'
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: newBengaliCon,
            onChanged: (v)=>newBengali=v,
            maxLines: 5,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'বাংলা'
            ),
          ),
        ],
      ),
    ):noInternet();
  }
}

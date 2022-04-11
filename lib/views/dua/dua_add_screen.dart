import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/configs/my_sizes.dart';

class DuaAddScreen extends StatefulWidget {
  const DuaAddScreen({Key? key}) : super(key: key);

  @override
  State<DuaAddScreen> createState() => _DuaAddScreenState();
}

class _DuaAddScreenState extends State<DuaAddScreen> {

  bool status = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checkConnectivity();
    checkRealtimeConnection();
  }

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
  Widget build(BuildContext context) {

    String? arabic,bengali,pronounce,title;

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
        title: Text('যোগ করুন',style: TextStyle(
            color: MyColors.text
        )),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (){
                if(title != null && pronounce != null && bengali != null && arabic != null){
                  FirebaseFirestore.instance
                      .collection("Dua's")
                      .add({
                    'title': title,
                    'pronounce': pronounce,
                    'bengali': bengali,
                    'arabic': arabic
                  });
                  Navigator.pop(context);
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('অনুগ্রহ করে সম্পূর্ণ ফিল্ড যোগ করুন'),
                        backgroundColor: MyColors.delete,
                      )
                  );
                }

              },
              icon: Icon(Icons.done, color: MyColors.primary,)
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(MySizes.paddingBody),
        children: [
          const SizedBox(height: 20,),
          TextField(
            onChanged: (v)=>title=v,
            decoration: const InputDecoration(
              labelText: 'শিরোনাম',
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 20,),
          TextField(
            onChanged: (v)=>arabic=v,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'আরবি',
                border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 20,),
          TextField(
            onChanged: (v)=>pronounce=v,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'উচ্চারণ',
                border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 20,),
          TextField(
            onChanged: (v)=>bengali=v,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'বাংলা',
                border: OutlineInputBorder()
            ),
          ),
        ],
      ),
    ):noInternet();
  }
}

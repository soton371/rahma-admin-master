import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/views/all_quran/surah_edit_screen.dart';

class SurahDetailsScreen extends StatefulWidget {
  String title;
  int id;
  SurahDetailsScreen({required this.id,required this.title});

  @override
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  // const SurahDetailsScreen({Key? key,required this.title,required this.id}) : super(key: key);
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
        title: Text(widget.title,
          style: TextStyle(
              color: MyColors.text
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('alQuran').doc('${widget.id - 1}').collection('details').orderBy('ayat_no', descending: false).snapshots(),
            builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
              if(!snapshot.hasData){
                return const Center(child: CircularProgressIndicator());
              }
              else {
                return ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: snapshot.data!.docs.map((document){
                      return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_)=>SurahEditScreen(ayatId: document['ayat_no'],surahId: document['surah_id'], receivedPronounce: document['pronounce'],ayatArabic: document['arabic'],audioUrl: document['audio'],)));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                      child: Text(document['arabic'],
                                      textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                        ),
                                      )
                                  ),
                                  Text(document['pronounce']==''?'উচ্চারণ এখনো সংকলন করা হয় নাই':"উচ্চারণ: ${document['pronounce']}"),
                                  Text("অনুবাদ: ${document['bangla']}"),
                                ],
                              ),
                            ),
                            // child: Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Column(
                            //     children: [
                            //       Text(document['arabic'],
                            //       style: TextStyle(
                            //         fontSize: 20,
                            //         fontWeight: FontWeight.bold
                            //       ),
                            //         textAlign: TextAlign.right,
                            //       ),
                            //       Text(document['pronounce']==''?'উচ্চারণ এখনো সংকলন করা হয় নাই':document['pronounce']),
                            //       Text(document['bangla']),
                            //       Text("আয়াত ${document['ayat_no'].toString()}"),
                            //     ],
                            //   ),
                            // ),
                          )
                      );

                    }).toList()
                );
              }
            }),
    ): noInternet();
  }
}

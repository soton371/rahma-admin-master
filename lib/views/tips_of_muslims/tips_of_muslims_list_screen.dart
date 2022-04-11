import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/configs/my_sizes.dart';
import 'package:rahma_admin/views/tips_of_muslims/tips_of_muslims_add_screen.dart';
import 'package:rahma_admin/views/tips_of_muslims/tips_of_muslims_edit_screen.dart';

class TipsOfMuslimsListScreen extends StatefulWidget {
  const TipsOfMuslimsListScreen({Key? key}) : super(key: key);

  @override
  State<TipsOfMuslimsListScreen> createState() => _TipsOfMuslimsListScreenState();
}

class _TipsOfMuslimsListScreenState extends State<TipsOfMuslimsListScreen> {

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
        title: Text('পরামর্শ সমূহ',style: TextStyle(
            color: MyColors.text
        )),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const TipsOfMuslimsAddScreen())),
              icon: Icon(Icons.add, color: MyColors.primary,)
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("tipsOfIslam").snapshots(),
          builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
            if(!snapshot.hasData){
              return const Center(child: CircularProgressIndicator());
            }
            else {
              return ListView(
                padding: EdgeInsets.symmetric(vertical: MySizes.paddingBody),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: snapshot.data!.docs.map((document){

                    return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TipsOfMuslimsEditScreen(docId: document.id, data: document['quotes'])));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ListTile(
                            title: Text(document['quotes']),
                          ),
                        )
                    );

                  }).toList()
              );
            }
          }),
    ):noInternet();
  }
}

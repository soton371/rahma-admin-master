import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rahma_admin/configs/my_colors.dart';
import 'package:rahma_admin/configs/my_sizes.dart';
import 'package:rahma_admin/views/all_quran/surah_list_screen.dart';
import 'package:rahma_admin/views/dua/dua_list_screen.dart';
import 'package:rahma_admin/views/madrasa_atimkhana/madrasa_atimkhana_list.dart';
import 'package:rahma_admin/views/namaz_shikkha/namaz_shikkha_list_screen.dart';
import 'package:rahma_admin/views/tips_of_muslims/tips_of_muslims_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

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
        elevation: 0,
        backgroundColor: MyColors.background,
        title: Text("Dashboard",
        style: TextStyle(
          color: MyColors.text
        ),
        )
      ),
      body: GridView(
        padding: EdgeInsets.all(MySizes.paddingBody),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5
          ),
        children: [
          InkWell(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const SurahListScreen())),
            child: MyCard('assets/images/holy-quran-icon-design-vector-eps-illustration-best-print-media-web-application-user-interface-infographics-132410981-removebg-preview.png', 'All-Quran')
          ),
          InkWell(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const NamajShikkhaListScreen())),
            child: MyCard('assets/images/pngtree-islamic-prayer-design-png-image_6146318-removebg-preview.png', 'Namaz Shikkha')
          ),
          InkWell(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const MadrasaAtimkhanaListScreen())),
            child: MyCard('assets/images/ezgif.com-gif-maker__5_-removebg-preview.png', 'Madrasa Atimkhana')
          ),
          InkWell(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const TipsOfMuslimsListScreen())),
            child: MyCard('assets/images/15a4be5bba8be00be6e1aa52eaf53ef2-removebg-preview.png', 'Tips of Muslims'),
          ),
          InkWell(
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const DuaListScreen())),
            child: MyCard('assets/images/islamic-prayer-flat-style-colorful-cartoon-vector-11629301-removebg-preview.png', "Dua's"),
          ),
          // InkWell(
          //   onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const DemoScreen())),
          //   child: MyCard('assets/images/islamic-prayer-flat-style-colorful-cartoon-vector-11629301-removebg-preview.png', "Demo"),
          // ),
        ],
      )
    ):noInternet();
  }
}


Widget MyCard(String myImage,String myText){
  return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(myImage,height: 60,),
        const SizedBox(height: 15,),
        Text(myText,
        style: const TextStyle(
          fontWeight: FontWeight.bold
        ),
        ),
      ],
    ),
  );
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rahma_admin/views/dashboard/dashboard_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rahma Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: DemoScreen()
      home: const DashboardScreen(),
    );
  }
}


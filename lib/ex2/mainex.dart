import 'package:api_http/ex2/homepage3.dart';
import 'package:api_http/example/code.dart';
import 'package:api_http/example/homepage2.dart';
import 'package:api_http/example/hompage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home:   const MyHomePage3(),
      getPages: [
        GetPage(name: '/', page: () => const MyHomePage3()),
      ],
    );
  }
}









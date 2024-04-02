import 'package:api_http/api_call.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDcLwYpQKKnIjA8gZFwz3FP_Jn8WicmQY0",
      appId: "1:3268331263:android:c5d0d0e78fb359a666aeca",
      messagingSenderId: "3268331263",
      projectId: "ikara-development",
      authDomain:'ikara-development.firebaseapp.com',
      databaseURL:'https://ikara-development-default-rtdb.firebaseio.com/',
      storageBucket:'ikara-development.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //let's create a seperate file for our api calls

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('API Development'),
            elevation: 5,
          ),
          body: ApiCall()),
    );
  }
}

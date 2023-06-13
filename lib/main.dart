import 'package:appointify/notification_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'view/welcome_page.dart';
import 'package:flutter/services.dart';
import 'dart:async';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFcm();

  runApp(const MyApp());
}

DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return MaterialApp(
      title: 'Appointify',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const WelcomePage(),
    );
  }
}

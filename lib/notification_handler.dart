import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initFcm() async {
  await Firebase.initializeApp();
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');
  var logger = Logger();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    if (FirebaseAuth.instance.currentUser != null) {
      // Redirect the user to the homepage
      // final firebaseApp = Firebase.app();
      // final rtdb = FirebaseDatabase.instanceFor(
      //   app: firebaseApp,
      //   databaseURL:
      //       'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
      // );

      DatabaseReference nameRef =
          FirebaseDatabase.instance.ref().child('students/$userID/designation');
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');
      DatabaseReference profRef =
          FirebaseDatabase.instance.ref().child('professors');
      nameRef.onValue.listen((event) async {
        try {
          String name = event.snapshot.value.toString();
          // ignore: unnecessary_null_comparison
          if (name == "Student") {
            final fcmToken = await FirebaseMessaging.instance.getToken();

            await ref.child(userID!).update({
              'fcmToken': fcmToken,
            });

            // ignore: use_build_context_synchronously
          } else {
            final fcmToken = await FirebaseMessaging.instance.getToken();

            await profRef.child(userID!).update({
              'fcmProfToken': fcmToken,
            });
          }
        } catch (error, stackTrace) {
          logger.d('Error occurred: $error');
          logger.d('Stack trace: $stackTrace');
        }
      });
    }
    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  }).onError((err) {
    logger.d('Error occurred: $err');
  });

  if (fcmToken != null) {
    await ref.child(userID.toString()).update({
      'fcmToken': fcmToken,
    });
  }

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
    RemoteNotification? notification = message?.notification;
    AndroidNotification? android = message?.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
            android: AndroidNotificationDetails('channel.id', 'channel.name',
                styleInformation: BigTextStyleInformation(''))),
        payload: json.encode(message?.data),
      );
    }
  });
}

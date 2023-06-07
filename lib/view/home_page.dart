import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  String name = '';
  String appointments = '';
  List<String> appointmentList = [];
  StreamSubscription<DatabaseEvent>? nameSubscription, appointmentsSubscription;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    _listenToDataUpdates();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    appointmentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _listenToDataUpdates() async {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );

    DatabaseReference nameRef = rtdb.ref().child('students/$userID/firstName');
    nameSubscription = nameRef.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            name = event.snapshot.value.toString();
            isLoading = false;
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    DatabaseReference appointmentsRef =
        rtdb.ref().child('studentAppointments/$userID/');
    appointmentsSubscription = appointmentsRef.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            appointments = event.snapshot.value.toString();
            appointmentList.add(appointments);
            isLoading = false;
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading ? const CircularProgressIndicator() : Text("Hi, $name!"),
            isLoading ? const CircularProgressIndicator() : Text(appointments),
            if (isLoading)
              const CircularProgressIndicator()
            else if (appointmentList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: appointmentList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(appointmentList[index]),
                    );
                  },
                ),
              )
            else
              const Text('No appointments found.'),
          ],
        ),
      ),
    );
  }
}

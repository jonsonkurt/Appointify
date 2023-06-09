import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

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
  StreamSubscription<DatabaseEvent>? nameSubscription;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );

    DatabaseReference nameRef =
        rtdb.ref().child('professors/$userID/firstName');
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

    DatabaseReference appointmentsRef = rtdb.ref('appointments/');
    // appointmentsRef.orderByChild('status').equalTo("$userID-PENDING");

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const SizedBox(
              width: 350,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hi, $name!",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ready to Fulfill Your Appointment?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            Container(width: 350, height: 1, color: Colors.black),
            const SizedBox(height: 10),
            const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Appointment",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            SizedBox(
              height: 350,
              width: 350,
              child: ContainedTabBarView(
                tabs: const [
                  Text('Upcoming'),
                  Text('Completed'),
                  Text('Canceled'),
                ],
                tabBarProperties: TabBarProperties(
                  width: 300,
                  height: 32,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset: const Offset(1, -1),
                        ),
                      ],
                    ),
                  ),
                  position: TabBarPosition.top,
                  alignment: TabBarAlignment.center,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                ),
                views: [
                  // Tab for Upcoming
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: FirebaseAnimatedList(
                            query: appointmentsRef
                                .orderByChild('requestStatusProfessor')
                                .equalTo("$userID-UPCOMING"),
                            itemBuilder: (context, snapshot, animation, index) {
                              return SizedBox(
                                  height: 150,
                                  child: Card(
                                      child: Column(
                                    children: [
                                      Text(
                                        snapshot
                                            .child('studentName')
                                            .value
                                            .toString(),
                                      ),
                                      Text(
                                        snapshot
                                            .child('studentSection')
                                            .value
                                            .toString(),
                                      ),
                                      Text(
                                        snapshot.child('date').value.toString(),
                                      ),
                                      Text(
                                        snapshot.child('time').value.toString(),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Handle button press
                                                  // Add your desired functionality here
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5, right: 5)),
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Handle button press
                                                  // Add your desired functionality here
                                                },
                                                child: const Text('Reschedule'),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  )));
                            },
                          ),
                        ),
                      )),

                  // Tab for completed
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: FirebaseAnimatedList(
                            query: appointmentsRef
                                .orderByChild('requestStatusProfessor')
                                .equalTo("$userID-COMPLETED"),
                            itemBuilder: (context, snapshot, animation, index) {
                              return SizedBox(
                                  height: 100,
                                  child: Card(
                                      child: Column(
                                    children: [
                                      Text(
                                        snapshot
                                            .child('professorName')
                                            .value
                                            .toString(),
                                      ),
                                      Text(
                                        snapshot
                                            .child('professorRole')
                                            .value
                                            .toString(),
                                      ),
                                      Text(
                                        snapshot.child('date').value.toString(),
                                      ),
                                      Text(
                                        snapshot.child('time').value.toString(),
                                      ),
                                    ],
                                  )));
                            },
                          ),
                        ),
                      )),

                  // Tab for Canceled
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: FirebaseAnimatedList(
                            query: appointmentsRef
                                .orderByChild('requestStatusProfessor')
                                .equalTo("$userID-CANCELED"),
                            itemBuilder: (context, snapshot, animation, index) {
                              return SizedBox(
                                  height: 100,
                                  child: Card(
                                      child: Column(
                                    children: [
                                      Text(
                                        snapshot
                                            .child('professorName')
                                            .value
                                            .toString(),
                                      ),
                                      Text(
                                        snapshot
                                            .child('professorRole')
                                            .value
                                            .toString(),
                                      ),
                                      Text(
                                        snapshot.child('date').value.toString(),
                                      ),
                                      Text(
                                        snapshot.child('time').value.toString(),
                                      ),
                                    ],
                                  )));
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

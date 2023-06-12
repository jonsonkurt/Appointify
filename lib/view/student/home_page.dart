import 'dart:async';
import 'dart:io';
import 'package:appointify/view/student/profile_controller.dart';
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
  String picRef = '';
  StreamSubscription<DatabaseEvent>? nameSubscription, picSubscription;

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

    DatabaseReference appointmentsRef = rtdb.ref('appointments/');
    DatabaseReference employeesRef = rtdb.ref('professors/');
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
                    "Ready to Set an Appointment?",
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
                    "Status of Request",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            Flexible(
              child: SizedBox(
                width: 350,
                child: FirebaseAnimatedList(
                  query: appointmentsRef
                      .orderByChild('status')
                      .equalTo("$userID-PENDING"),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, snapshot, animation, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Theme(
                            data: Theme.of(context).copyWith(
                                dialogBackgroundColor: const Color(0xFF767676)),
                            child: AlertDialog(
                              content: SizedBox(
                                height: 380,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Professor Name:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        snapshot
                                            .child('professorName')
                                            .value
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Designation:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        snapshot
                                            .child('professorRole')
                                            .value
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Requested Appointment:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "${snapshot.child('date').value}, ${snapshot.child('time').value}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      if (snapshot.child('notes').value != "")
                                        const Text(
                                          'Notes:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      Text(
                                        snapshot
                                            .child('notes')
                                            .value
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (snapshot.child('countered').value ==
                                          "yes")
                                        const Text(
                                          'Counter Proposal:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      if (snapshot.child('countered').value ==
                                          "yes")
                                        Text(
                                          "${snapshot.child('counteredDate').value}, ${snapshot.child('counteredTime').value}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      if (snapshot.child('countered').value ==
                                          "yes")
                                        ElevatedButton(
                                          onPressed: () {
                                            // Handle button press
                                            // Add your desired functionality here
                                            appointmentsRef
                                                .child(snapshot
                                                    .child('appointID')
                                                    .value
                                                    .toString())
                                                .update({
                                              "requestStatus": "UPCOMING",
                                              "date": snapshot
                                                  .child('counteredDate')
                                                  .value
                                                  .toString(),
                                              "time": snapshot
                                                  .child('counteredTime')
                                                  .value
                                                  .toString(),
                                              "requestStatusProfessor":
                                                  "${snapshot.child('professorID').value}-UPCOMING",
                                              "status": "$userID-UPCOMING",
                                            });
                                          },
                                          child: const Text('Accept'),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      // Status of request list
                      child: SizedBox(
                        width: 150,
                        child: Card(
                          child: Column(
                            children: [
                              Flexible(
                                child: FirebaseAnimatedList(
                                  query: employeesRef
                                      .orderByChild('profUserID')
                                      .equalTo(snapshot
                                          .child('professorID')
                                          .value
                                          .toString()),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (context, snapshot, animation, index) {
                                    return SizedBox(
                                      child: Center(
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 35, 35, 35),
                                                width: 2,
                                              )),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: ProfileController()
                                                          .image ==
                                                      null
                                                  ? snapshot
                                                              .child(
                                                                  'profilePicStatus')
                                                              .value
                                                              .toString() ==
                                                          "None"
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 35,
                                                        )
                                                      : Image(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                              snapshot
                                                                  .child(
                                                                      'profilePicStatus')
                                                                  .value
                                                                  .toString()),
                                                          loadingBuilder: (context,
                                                              child,
                                                              loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return const CircularProgressIndicator();
                                                          },
                                                          errorBuilder:
                                                              (context, object,
                                                                  stack) {
                                                            return const Icon(
                                                              Icons
                                                                  .error_outline,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      35,
                                                                      35,
                                                                      35),
                                                            );
                                                          },
                                                        )
                                                  : Image.file(File(
                                                          ProfileController()
                                                              .image!
                                                              .path)
                                                      .absolute)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
                              if (snapshot.child('countered').value == "yes")
                                const Icon(
                                  Icons
                                      .info_outline, // Replace with the desired icon
                                  color: Colors
                                      .red, // Replace with the desired color
                                ),
                              Text(
                                snapshot
                                    .child('requestStatus')
                                    .value
                                    .toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
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
                ],
                tabBarProperties: TabBarProperties(
                  width: 200,
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
                                .orderByChild('status')
                                .equalTo("$userID-UPCOMING"),
                            itemBuilder: (context, snapshot, animation, index) {
                              return SizedBox(
                                  height: 100,
                                  child: Card(
                                      child: Column(
                                    children: [
                                      Flexible(
                                        child: FirebaseAnimatedList(
                                          query: employeesRef
                                              .orderByChild('profUserID')
                                              .equalTo(snapshot
                                                  .child('professorID')
                                                  .value
                                                  .toString()),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, snapshot,
                                              animation, index) {
                                            return SizedBox(
                                              child: Center(
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 35, 35, 35),
                                                        width: 2,
                                                      )),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: ProfileController()
                                                                  .image ==
                                                              null
                                                          ? snapshot
                                                                      .child(
                                                                          'profilePicStatus')
                                                                      .value
                                                                      .toString() ==
                                                                  "None"
                                                              ? const Icon(
                                                                  Icons.person,
                                                                  size: 35,
                                                                )
                                                              : Image(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image: NetworkImage(snapshot
                                                                      .child(
                                                                          'profilePicStatus')
                                                                      .value
                                                                      .toString()),
                                                                  loadingBuilder:
                                                                      (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null) {
                                                                      return child;
                                                                    }
                                                                    return const CircularProgressIndicator();
                                                                  },
                                                                  errorBuilder:
                                                                      (context,
                                                                          object,
                                                                          stack) {
                                                                    return const Icon(
                                                                      Icons
                                                                          .error_outline,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          35,
                                                                          35,
                                                                          35),
                                                                    );
                                                                  },
                                                                )
                                                          : Image.file(File(
                                                                  ProfileController()
                                                                      .image!
                                                                      .path)
                                                              .absolute)),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
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

                  // Tab for completed
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: FirebaseAnimatedList(
                            query: appointmentsRef
                                .orderByChild('status')
                                .equalTo("$userID-COMPLETED"),
                            itemBuilder: (context, snapshot, animation, index) {
                              return SizedBox(
                                  height: 100,
                                  child: Card(
                                      child: Column(
                                    children: [
                                      Flexible(
                                        child: FirebaseAnimatedList(
                                          query: employeesRef
                                              .orderByChild('profUserID')
                                              .equalTo(snapshot
                                                  .child('professorID')
                                                  .value
                                                  .toString()),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, snapshot,
                                              animation, index) {
                                            return SizedBox(
                                              child: Center(
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 35, 35, 35),
                                                        width: 2,
                                                      )),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: ProfileController()
                                                                  .image ==
                                                              null
                                                          ? snapshot
                                                                      .child(
                                                                          'profilePicStatus')
                                                                      .value
                                                                      .toString() ==
                                                                  "None"
                                                              ? const Icon(
                                                                  Icons.person,
                                                                  size: 35,
                                                                )
                                                              : Image(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image: NetworkImage(snapshot
                                                                      .child(
                                                                          'profilePicStatus')
                                                                      .value
                                                                      .toString()),
                                                                  loadingBuilder:
                                                                      (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null) {
                                                                      return child;
                                                                    }
                                                                    return const CircularProgressIndicator();
                                                                  },
                                                                  errorBuilder:
                                                                      (context,
                                                                          object,
                                                                          stack) {
                                                                    return const Icon(
                                                                      Icons
                                                                          .error_outline,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          35,
                                                                          35,
                                                                          35),
                                                                    );
                                                                  },
                                                                )
                                                          : Image.file(File(
                                                                  ProfileController()
                                                                      .image!
                                                                      .path)
                                                              .absolute)),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
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

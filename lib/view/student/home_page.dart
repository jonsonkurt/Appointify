import 'dart:async';
import 'dart:io';
import 'package:appointify/view/student/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
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

    DatabaseReference appointmentsRef = rtdb.ref('appointments');
    DatabaseReference employeesRef = rtdb.ref('professors/');
    // appointmentsRef.orderByChild('status').equalTo("$userID-PENDING");

    return Scaffold(
      body: SafeArea(
        child: Center(
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
                        fontFamily: "GothamRnd"
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
                        fontFamily: "GothamRnd"
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
                        fontFamily: "GothamRnd"
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
                        .startAt("$userID-PENDING")
                        .endAt("$userID-PENDING\uf8ff"),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, snapshot, animation, index) {
                      String inputDate =
                          snapshot.child("date").value.toString();
                      DateTime dateTime =
                          DateFormat('MMM dd, yyyy').parse(inputDate);
                      String outputDate =
                          DateFormat('MM-dd-yyyy').format(dateTime);
                      String inputTime =
                          snapshot.child("time").value.toString();
                      DateTime time = DateFormat('h:mm a').parse(inputTime);
                      String outputTime = DateFormat('HH:mm').format(time);
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  snapshot
                                              .child('countered')
                                              .value
                                              .toString() ==
                                          "no"
                                      ? snapshot
                                          .child('requestStatus')
                                          .value
                                          .toString()
                                      : "Reschedule",
                                  style: const TextStyle(fontSize: 20,fontFamily: "GothamRnd"),
                                ),
                                content: SizedBox(
                                  height: 200, // Set the desired height here
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Text(
                                        'Professor name:', style: TextStyle(fontFamily: "GothamRnd"),
                                      ),
                                      Center(
                                        child: Text(
                                          snapshot
                                              .child('professorName')
                                              .value
                                              .toString(),style: TextStyle(fontFamily: "GothamRnd"),
                                        ),
                                      ),
                                      const Text(
                                        'Designation:', style: TextStyle(fontFamily: "GothamRnd"),
                                      ),
                                      Center(
                                        child: Text(
                                          snapshot
                                              .child('professorRole')
                                              .value
                                              .toString(),style: TextStyle(fontFamily: "GothamRnd"),
                                        ),
                                      ),
                                      const Text('Requested Appointment:',style: TextStyle(fontFamily: "GothamRnd"),),
                                      Center(
                                        child: Text(
                                            '${snapshot.child('date').value} - ${snapshot.child('time').value}',
                                            style: TextStyle(fontFamily: "GothamRnd"),
                                            ),
                                            
                                      ),
                                      if (snapshot.child('countered').value ==
                                          "yes")
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Counter Proposal:',style: TextStyle(fontFamily: "GothamRnd"),
                                            ),
                                            Center(
                                              child: Text(
                                                '${snapshot.child('counteredDate').value} - ${snapshot.child('counteredTime').value}',
                                              style: TextStyle(fontFamily: "GothamRnd"),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (snapshot.child('countered').value ==
                                          "yes")
                                        ElevatedButton(
                                            child: const Text("Accept"),
                                            onPressed: () async {
                                              String inputDate = snapshot
                                                  .child("counteredDate")
                                                  .value
                                                  .toString();
                                              DateTime dateTime =
                                                  DateFormat('MMM dd, yyyy')
                                                      .parse(inputDate);
                                              String outputDate =
                                                  DateFormat('MM-dd-yyyy')
                                                      .format(dateTime);
                                              String inputTime = snapshot
                                                  .child("counteredTime")
                                                  .value
                                                  .toString();
                                              DateTime time =
                                                  DateFormat('h:mm a')
                                                      .parse(inputTime);
                                              String outputTime =
                                                  DateFormat('HH:mm')
                                                      .format(time);
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
                                                    "${snapshot.child('professorID').value}-UPCOMING-$outputDate:$outputTime",
                                                "status":
                                                    "$userID-UPCOMING-$outputDate:$outputTime",
                                                "countered": "no",
                                              });
                                              Navigator.of(context).pop();
                                            }),
                                      if (snapshot.child('countered').value ==
                                          "yes")
                                        ElevatedButton(
                                            child: const Text("Reject"),
                                            onPressed: () {
                                              appointmentsRef
                                                  .child(snapshot
                                                      .child('appointID')
                                                      .value
                                                      .toString())
                                                  .update({
                                                "requestStatus": "CANCELED",
                                                "requestStatusProfessor":
                                                    "${snapshot.child('professorID').value}-CANCELED-$outputDate:$outputTime",
                                                "status":
                                                    "$userID-CANCELED-$outputDate:$outputTime",
                                              });
                                              Navigator.of(context).pop();
                                            })
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        // Status of request list
                        child: SizedBox(
                          width: 150,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: const Color(0xffFF9343),
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
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 10),
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
                                                            size: 20,
                                                          )
                                                        : Image(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                snapshot
                                                                    .child(
                                                                        'profilePicStatus')
                                                                    .value
                                                                    .toString()),
                                                            loadingBuilder:
                                                                (context, child,
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
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 3,
                                  ),
                                  child: Text(
                                    snapshot
                                        .child('professorName')
                                        .value
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily: "GothamRnd",
                                    ),
                                  ),
                                ),
                                Text(
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
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
                                Container(
                                  alignment: Alignment.center,
                                  height: 20,
                                  width: 150,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF4394FF),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20))),
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    snapshot
                                                .child('countered')
                                                .value
                                                .toString() ==
                                            "no"
                                        ? snapshot
                                            .child('requestStatus')
                                            .value
                                            .toString()
                                        : "RESCHEDULE",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "GothamRnd",
                                        ),
                                  ),
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
                        fontFamily: "GothamRnd"
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                height: 350,
                width: 350,
                child: ContainedTabBarView(
                  tabs: const [
                    Text(
                      'Upcoming',
                      style: TextStyle(fontSize: 15,  fontFamily: "GothamRnd"),
                    ),
                    Text(
                      'Completed',
                      style: TextStyle(fontSize: 15,fontFamily: "GothamRnd"),
                    ),
                    Text(
                      'Canceled',
                      style: TextStyle(fontSize: 15,fontFamily: "GothamRnd"),
                    ),
                  ],
                  tabBarProperties: TabBarProperties(
                    width: 360,
                    height: 50,
                    indicator: const ContainerTabIndicator(
                      color: Colors.orange,
                      radius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
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
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black38,
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
                                .startAt("$userID-UPCOMING")
                                .endAt("$userID-UPCOMING\uf8ff"),
                            itemBuilder: (context, snapshot, animation, index) {
                              String employeeName = snapshot
                                  .child('professorName')
                                  .value
                                  .toString();
                              String employeePosition = snapshot
                                  .child('professorRole')
                                  .value
                                  .toString();
                              String schedDate =
                                  snapshot.child('date').value.toString();
                              String schedTime =
                                  snapshot.child('time').value.toString();
                              return SizedBox(
                                  height: 100,
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: Colors.white12,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: FirebaseAnimatedList(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
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
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15,
                                                                top: 15),
                                                        child: Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        35,
                                                                        35,
                                                                        35),
                                                                    width: 2,
                                                                  )),
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child: ProfileController()
                                                                          .image ==
                                                                      null
                                                                  ? snapshot.child('profilePicStatus').value.toString() ==
                                                                          "None"
                                                                      ? const Icon(
                                                                          Icons
                                                                              .person,
                                                                          size:
                                                                              35,
                                                                        )
                                                                      : Image(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          image: NetworkImage(snapshot
                                                                              .child('profilePicStatus')
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
                                                                          errorBuilder: (context,
                                                                              object,
                                                                              stack) {
                                                                            return const Icon(
                                                                              Icons.error_outline,
                                                                              color: Color.fromARGB(255, 35, 35, 35),
                                                                            );
                                                                          },
                                                                        )
                                                                  : Image.file(File(ProfileController()
                                                                          .image!
                                                                          .path)
                                                                      .absolute)),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            employeeName,
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight.bold, 
                                                                    fontFamily: "GothamRnd"),
                                                          ),
                                                          Text(
                                                            employeePosition,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:15,
                                                                    fontFamily: "GothamRnd"),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.centerLeft,
                                                            height:  MediaQuery.of(context).size.height/35,
                                                            width: MediaQuery.of(context).size.width/2,
                                                            padding:EdgeInsets.only(left: 20),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  schedDate,
                                                                  style: const TextStyle(
                                                                      fontSize:15,
                                                                      fontFamily: "GothamRnd"),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  
                                                                  schedTime,
                                                                  style: const TextStyle(
                                                                      fontSize:15,
                                                                      fontFamily: "GothamRnd"),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      )));
                            },
                          ),
                        ),
                      ),
                    ),

                    // Tab for Completed
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: FirebaseAnimatedList(
                            query: appointmentsRef
                                .orderByChild('status')
                                .startAt("$userID-COMPLETED")
                                .endAt("$userID-COMPLETED\uf8ff"),
                            itemBuilder: (context, snapshot, animation, index) {
                              String employeeName = snapshot
                                  .child('professorName')
                                  .value
                                  .toString();
                              String employeePosition = snapshot
                                  .child('professorRole')
                                  .value
                                  .toString();
                              String schedDate =
                                  snapshot.child('date').value.toString();
                              String schedTime =
                                  snapshot.child('time').value.toString();
                              return SizedBox(
                              
                                  height: 100,
                                  child: Card(
                                    color: Colors.white12,
                                      child: Row(
                                    children: [
                                      Flexible(
                                        child: FirebaseAnimatedList(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
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
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15, top: 15),
                                                    child: Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                35, 35, 35),
                                                            width: 2,
                                                          )),
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                                      Icons
                                                                          .person,
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
                                                                      loadingBuilder: (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                        if (loadingProgress ==
                                                                            null) {
                                                                          return child;
                                                                        }
                                                                        return const CircularProgressIndicator();
                                                                      },
                                                                      errorBuilder: (context,
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
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        employeeName, style: TextStyle(fontFamily: "GothamRnd",
                                                        fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        employeePosition, style: TextStyle(fontFamily: "GothamRnd")
                                                      ),
                                                      Container(
                                                        height:  MediaQuery.of(context).size.height/35,
                                                            width: MediaQuery.of(context).size.width/2,
                                                            padding:EdgeInsets.only(left: 20),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              schedDate, style: TextStyle(fontFamily: "GothamRnd")
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              schedTime, style: TextStyle(fontFamily: "GothamRnd")
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )));
                            },
                          ),
                        ),
                      ),
                    ),

                    // Tab for Canceled
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        child: SizedBox(
                          width: 350,
                          height: 300,
                          child: FirebaseAnimatedList(
                            query: appointmentsRef
                                .orderByChild('status')
                                .startAt("$userID-CANCELED")
                                .endAt("$userID-CANCELED\uf8ff"),
                            itemBuilder: (context, snapshot, animation, index) {
                              String employeeName = snapshot
                                  .child('professorName')
                                  .value
                                  .toString();
                              String employeePosition = snapshot
                                  .child('professorRole')
                                  .value
                                  .toString();
                              String schedDate =
                                  snapshot.child('date').value.toString();
                              String schedTime =
                                  snapshot.child('time').value.toString();
                              return SizedBox(
                                  height: 100,
                                  child: GestureDetector(
                                    onTap: () {
                                      String profNotes = snapshot
                                          .child('notes')
                                          .value
                                          .toString();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Professor Note'),
                                              content: Text(profNotes),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Close',style: TextStyle(fontFamily: "GothamRnd")),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Card(
                                      color: Colors.white12,
                                        child: Row(
                                      children: [
                                        Flexible(
                                          child: FirebaseAnimatedList(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
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
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15,
                                                              top: 15),
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      35,
                                                                      35,
                                                                      35),
                                                                  width: 2,
                                                                )),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            35,
                                                                      )
                                                                    : Image(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: NetworkImage(snapshot
                                                                            .child('profilePicStatus')
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
                                                                        errorBuilder: (context,
                                                                            object,
                                                                            stack) {
                                                                          return const Icon(
                                                                            Icons.error_outline,
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
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          employeeName, style: TextStyle(fontFamily: "GothamRnd",
                                                          fontWeight: FontWeight.bold)
                                                        ),
                                                        Text(
                                                          employeePosition, style: TextStyle(fontFamily: "GothamRnd")
                                                        ),
                                                        Container(
                                                          height:  MediaQuery.of(context).size.height/35,
                                                            width: MediaQuery.of(context).size.width/2,
                                                            padding:EdgeInsets.only(left: 20),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                schedDate, style: TextStyle(fontFamily: "GothamRnd")
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                schedTime, style: TextStyle(fontFamily: "GothamRnd")
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                  ));
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

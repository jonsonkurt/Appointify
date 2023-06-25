import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import '../student/profile_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  bool isEmptyUpcoming = true;
  bool isEmptyCompleted = true;
  bool isEmptyCanceled = true;
  String name = '';
  StreamSubscription<DatabaseEvent>? nameSubscription,
      emptyUpcomingSubscription,
      emptyCompletedSubscription,
      emptyCanceledSubscription;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    emptyUpcomingSubscription?.cancel();
    emptyCompletedSubscription?.cancel();
    emptyCanceledSubscription?.cancel();
    super.dispose();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _dateController.text = DateFormat.yMMMd('en_US').format(selectedDate);
      }
    });
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((selectedTime) {
      if (selectedTime != null) {
        _timeController.text = selectedTime.format(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference nameRef =
        FirebaseDatabase.instance.ref().child('professors/$userID/firstName');
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

    // Database references and queries for empty views
    DatabaseReference emptyPendingRef =
        FirebaseDatabase.instance.ref('appointments');
    Query emptyUpcomingQuery = emptyPendingRef
        .orderByChild('requestStatusProfessor')
        .startAt("$userID-UPCOMING")
        .endAt("$userID-UPCOMING\uf8ff");
    Query emptyCompletedQuery = emptyPendingRef
        .orderByChild('requestStatusProfessor')
        .startAt("$userID-COMPLETED")
        .endAt("$userID-COMPLETED\uf8ff");
    Query emptyCanceledQuery = emptyPendingRef
        .orderByChild('requestStatusProfessor')
        .startAt("$userID-CANCELED")
        .endAt("$userID-CANCELED\uf8ff");

    emptyUpcomingSubscription = emptyUpcomingQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyUpcoming = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
    emptyCompletedSubscription = emptyCompletedQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyCompleted = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
    emptyCanceledSubscription = emptyCanceledQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyCanceled = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    DatabaseReference appointmentsRef =
        FirebaseDatabase.instance.ref('appointments/');
    DatabaseReference completedRef =
        FirebaseDatabase.instance.ref('appointments/');
    DatabaseReference canceledRef =
        FirebaseDatabase.instance.ref('appointments/');
    DatabaseReference studentsRef = FirebaseDatabase.instance.ref('students/');
    // appointmentsRef.orderByChild('status').equalTo("$userID-PENDING");

    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
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
                            fontFamily: "GothamRnd"),
                      ),
                    )),
                const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ready for Your Appointment?",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "GothamRnd"),
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
                            fontFamily: "GothamRnd"),
                      ),
                    )),
                const SizedBox(height: 10),
                Flexible(
                  // height: 350,
                  // width: 500,
                  child: ContainedTabBarView(
                    tabs: const [
                      Text(
                        'Upcoming',
                        style: TextStyle(fontSize: 15, fontFamily: "GothamRnd"),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(fontSize: 15, fontFamily: "GothamRnd"),
                      ),
                      Text(
                        'Canceled',
                        style: TextStyle(fontSize: 15, fontFamily: "GothamRnd"),
                      ),
                    ],
                    tabBarProperties: TabBarProperties(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 30,
                          right: MediaQuery.of(context).size.width / 30),
                      width: 360,
                      height: 50,
                      indicator: const ContainerTabIndicator(
                        color: Color(0xFF274C77),
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
                      unselectedLabelColor: Colors.black,
                    ),
                    views: [
                      // Tab for Upcoming
                      if (isEmptyUpcoming)
                        const SizedBox(
                          // color: Colors.red,
                          height: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No Available Data",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "GothamRnd"),
                              ),
                            ],
                          ),
                        ),
                      if (!isEmptyUpcoming)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            width: 350,
                            height: 600,
                            child: FirebaseAnimatedList(
                              query: appointmentsRef
                                  .orderByChild('requestStatusProfessor')
                                  .startAt("$userID-UPCOMING")
                                  .endAt("$userID-UPCOMING\uf8ff"),
                              itemBuilder:
                                  (context, snapshot, animation, index) {
                                String studentName = snapshot
                                    .child('studentName')
                                    .value
                                    .toString();
                                String studentSection =
                                    snapshot.child('section').value.toString();
                                String appointID = snapshot
                                    .child('appointID')
                                    .value
                                    .toString();
                                String professorID = snapshot
                                    .child('professorID')
                                    .value
                                    .toString();
                                String studentID = snapshot
                                    .child('studentID')
                                    .value
                                    .toString();
                                String inputDate =
                                    snapshot.child("date").value.toString();
                                DateTime dateTime =
                                    DateFormat('MMM dd, yyyy').parse(inputDate);
                                String outputDate =
                                    DateFormat('MM-dd-yyyy').format(dateTime);
                                String inputTime =
                                    snapshot.child("time").value.toString();
                                DateTime time =
                                    DateFormat('h:mm a').parse(inputTime);
                                String outputTime =
                                    DateFormat('HH:mm').format(time);

                                return SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const SizedBox(height: 15),
                                            Flexible(
                                              child: FirebaseAnimatedList(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                query: studentsRef
                                                    .orderByChild('UID')
                                                    .equalTo(snapshot
                                                        .child('studentID')
                                                        .value
                                                        .toString()),
                                                itemBuilder: (context, snapshot,
                                                    animation, index) {
                                                  return SizedBox(
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 10),
                                                        Container(
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
                                                              studentName,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    "GothamRnd",
                                                              ),
                                                            ),
                                                            Text(
                                                              studentSection,
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  0.5,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  25,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      15,
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      15),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    width: 2,
                                                  )),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            20,
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            20),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        Text(
                                                          snapshot
                                                              .child('date')
                                                              .value
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "GothamRnd"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 30,
                                                            left: 20),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .watch_later_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        Text(
                                                          snapshot
                                                              .child('time')
                                                              .value
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "GothamRnd"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        40,
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            40,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                            fixedSize: MaterialStatePropertyAll(Size(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                20)),
                                                            shape: const MaterialStatePropertyAll(
                                                                RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20)),
                                                            )),
                                                            backgroundColor:
                                                                const MaterialStatePropertyAll(
                                                              Color(
                                                                  0xFF6096BA), // card button color
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            // Handle button press
                                                            // Add your desired functionality here
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Form(
                                                                  key: formKey,
                                                                  child:
                                                                      AlertDialog(
                                                                    titlePadding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            0),
                                                                    title:
                                                                        Container(
                                                                      height:
                                                                          70,
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                      color: const Color(
                                                                          0xFF274C77),
                                                                      child:
                                                                          const Text(
                                                                        'Reschedule',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontFamily:
                                                                                "GothamRnd",
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Column(
                                                                          children: [
                                                                            const Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                "Appointment Date:",
                                                                                style: TextStyle(
                                                                                  fontFamily: "GothamRnd",
                                                                                  color: Color(0xFF393838),
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 5),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: TextFormField(
                                                                                    controller: _dateController,
                                                                                    onTap: _showDatePicker,
                                                                                    readOnly: true,
                                                                                    decoration: const InputDecoration(
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                          borderSide: BorderSide(width: 1, color: Colors.black), //<-- SEE HERE
                                                                                        ),
                                                                                        hintText: 'Select appointment date',
                                                                                        hintStyle: TextStyle(fontFamily: "GothamRnd", fontSize: 12),
                                                                                        helperStyle: TextStyle(fontFamily: "GothamRnd")),
                                                                                    validator: (value) {
                                                                                      if (value == null || value.isEmpty) {
                                                                                        return 'Please enter a date';
                                                                                      }
                                                                                      return null; // Return null if there is no error
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(height: 10),
                                                                            const Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                "Appointment Time:",
                                                                                style: TextStyle(
                                                                                  fontFamily: "GothamRnd",
                                                                                  color: Color(0xFF393838),
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 5),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            Expanded(
                                                                              child: TextFormField(
                                                                                controller: _timeController,
                                                                                onTap: _showTimePicker,
                                                                                readOnly: true,
                                                                                decoration: const InputDecoration(
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                      borderSide: BorderSide(width: 1, color: Colors.black), //<-- SEE HERE
                                                                                    ),
                                                                                    hintText: 'Select appointment time',
                                                                                    hintStyle: TextStyle(fontFamily: "GothamRnd", fontSize: 12),
                                                                                    helperStyle: TextStyle(fontFamily: "GothamRnd")),
                                                                                validator: (value) {
                                                                                  if (value == null || value.isEmpty) {
                                                                                    return 'Please enter a time';
                                                                                  }
                                                                                  return null; // Return null if there is no error
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        child:
                                                                            const Text(
                                                                          'OK',
                                                                          style:
                                                                              TextStyle(fontFamily: "GothamRnd"),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          if (formKey
                                                                              .currentState!
                                                                              .validate()) {
                                                                            await appointmentsRef.child(appointID.toString()).update({
                                                                              "countered": "yes",
                                                                              "requestStatusProfessor": "$professorID-RESCHEDULE",
                                                                              "counteredDate": _dateController.text,
                                                                              "counteredTime": _timeController.text,
                                                                              "status": '$studentID-PENDING-$outputDate:$outputTime',
                                                                              "requestStatus": 'PENDING'
                                                                            });

                                                                            // ignore: use_build_context_synchronously
                                                                            Navigator.of(context).pop();
                                                                          }
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child:
                                                                            const Text(
                                                                          'Cancel',
                                                                          style:
                                                                              TextStyle(fontFamily: "GothamRnd"),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Reschedule',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                fontFamily:
                                                                    "GothamRnd"),
                                                          ),
                                                          // child: const Text('Reschedule'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                        height:
                                                            90, // gap between the button and the info
                                                      ),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                            fixedSize: MaterialStatePropertyAll(Size(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                20)),
                                                            shape: const MaterialStatePropertyAll(
                                                                RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20)),
                                                            )),
                                                            backgroundColor:
                                                                const MaterialStatePropertyAll(
                                                              Color(
                                                                  0xFF6096BA), // card button color
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  String
                                                                      profNotes =
                                                                      '';

                                                                  return Form(
                                                                    key:
                                                                        formKey,
                                                                    child:
                                                                        AlertDialog(
                                                                      titlePadding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              0),
                                                                      title:
                                                                          Container(
                                                                        height:
                                                                            70,
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            20),
                                                                        color: const Color(
                                                                            0xFF274C77),
                                                                        child:
                                                                            const Text(
                                                                          'State your reason.',
                                                                          style: TextStyle(
                                                                              fontSize: 20,
                                                                              fontFamily: "GothamRnd",
                                                                              color: Colors.white),
                                                                        ),
                                                                      ),
                                                                      content:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const SizedBox(
                                                                              height: 10),
                                                                          TextFormField(
                                                                            onChanged:
                                                                                (value) {
                                                                              profNotes = value;
                                                                            },
                                                                            maxLines:
                                                                                null,
                                                                            keyboardType:
                                                                                TextInputType.multiline,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                borderSide: BorderSide(width: 1, color: Colors.black), //<-- SEE HERE
                                                                              ),
                                                                              hintText: 'Enter your reason',
                                                                              hintStyle: TextStyle(fontFamily: "GothamRnd", fontSize: 12),
                                                                              helperStyle: TextStyle(fontFamily: "GothamRnd"),
                                                                            ),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.isEmpty) {
                                                                                return 'Please enter a reason';
                                                                              }
                                                                              return null; // Return null if there is no error
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              const Text(
                                                                            'OK',
                                                                            style:
                                                                                TextStyle(fontFamily: "GothamRnd"),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            if (formKey.currentState!.validate()) {
                                                                              await appointmentsRef.child(appointID.toString()).update({
                                                                                'notes': profNotes,
                                                                                'requestStatusProfessor': "$professorID-CANCELED-$outputDate:$outputTime",
                                                                                'status': "$studentID-CANCELED-$outputDate:$outputTime",
                                                                                'requestStatus': "CANCELED",
                                                                              });
                                                                              // ignore: use_build_context_synchronously
                                                                              Navigator.of(context).pop();
                                                                            }
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              const Text(
                                                                            'Cancel',
                                                                            style:
                                                                                TextStyle(fontFamily: "GothamRnd"),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontFamily:
                                                                      "GothamRnd")),
                                                          // child: const Text('Cancel'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      Expanded(
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                            fixedSize: MaterialStatePropertyAll(Size(
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    4,
                                                                20)),
                                                            shape: const MaterialStatePropertyAll(
                                                                RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20)),
                                                            )),
                                                            backgroundColor:
                                                                const MaterialStatePropertyAll(
                                                              Color(
                                                                  0xFF6096BA), // card button color
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            // Handle button press
                                                            // Add your desired functionality here
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Are you sure you want to mark this appointment as completed?'),
                                                                    actions: [
                                                                      TextButton(
                                                                        child:
                                                                            const Text(
                                                                          'Confirm',
                                                                          style:
                                                                              TextStyle(fontFamily: "GothamRnd"),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await appointmentsRef
                                                                              .child(appointID.toString())
                                                                              .update({
                                                                            'requestStatusProfessor':
                                                                                "$professorID-COMPLETED-$outputDate:$outputTime",
                                                                            'status':
                                                                                "$studentID-COMPLETED-$outputDate:$outputTime",
                                                                            'requestStatus':
                                                                                "COMPLETED",
                                                                          });
                                                                          // ignore: use_build_context_synchronously
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      TextButton(
                                                                        child:
                                                                            const Text(
                                                                          'Cancel',
                                                                          style:
                                                                              TextStyle(fontFamily: "GothamRnd"),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                          child: const Text(
                                                              'Complete',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontFamily:
                                                                      "GothamRnd")),
                                                          // child: const Text('Completed'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ),

                      // Tab for completed
                      if (isEmptyCompleted)
                        const SizedBox(
                          // color: Colors.red,
                          height: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No Available Data",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "GothamRnd"),
                              ),
                            ],
                          ),
                        ),
                      if (!isEmptyCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            width: 350,
                            height: 600,
                            child: FirebaseAnimatedList(
                              query: completedRef
                                  .orderByChild('requestStatusProfessor')
                                  .startAt("$userID-COMPLETED")
                                  .endAt("$userID-COMPLETED\uf8ff"),
                              itemBuilder:
                                  (context, snapshot, animation, index) {
                                String studentName = snapshot
                                    .child('studentName')
                                    .value
                                    .toString();
                                String studentSection =
                                    snapshot.child('section').value.toString();
                                return SizedBox(
                                    height: 140,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const SizedBox(height: 15),
                                            Flexible(
                                              child: FirebaseAnimatedList(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                query: studentsRef
                                                    .orderByChild('UID')
                                                    .equalTo(snapshot
                                                        .child('studentID')
                                                        .value
                                                        .toString()),
                                                itemBuilder: (context, snapshot,
                                                    animation, index) {
                                                  return SizedBox(
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 10),
                                                        Container(
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
                                                              studentName,
                                                              style: const TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                            Text(
                                                              studentSection,
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      100,
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      15,
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      15),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  0.5,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  25,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.white,
                                                  border: Border.all(width: 2)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color: Colors.black,
                                                      ),
                                                      Text(
                                                        snapshot
                                                            .child('date')
                                                            .value
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "GothamRnd"),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .watch_later_outlined,
                                                        color: Colors.black,
                                                      ),
                                                      Text(
                                                        snapshot
                                                            .child('time')
                                                            .value
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "GothamRnd"),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ),

                      // Tab for Canceled
                      if (isEmptyCanceled)
                        const SizedBox(
                          // color: Colors.red,
                          height: 125,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "No Available Data",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "GothamRnd"),
                              ),
                            ],
                          ),
                        ),
                      if (!isEmptyCanceled)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SizedBox(
                            width: 350,
                            height: 600,
                            child: FirebaseAnimatedList(
                              query: canceledRef
                                  .orderByChild('requestStatusProfessor')
                                  .startAt("$userID-CANCELED")
                                  .endAt("$userID-CANCELED\uf8ff"),
                              itemBuilder:
                                  (context, snapshot, animation, index) {
                                String studentName = snapshot
                                    .child('studentName')
                                    .value
                                    .toString();
                                String studentSection =
                                    snapshot.child('section').value.toString();
                                return SizedBox(
                                    height: 140,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Card(
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            const SizedBox(height: 15),
                                            Flexible(
                                              child: FirebaseAnimatedList(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                query: studentsRef
                                                    .orderByChild('UID')
                                                    .equalTo(snapshot
                                                        .child('studentID')
                                                        .value
                                                        .toString()),
                                                itemBuilder: (context, snapshot,
                                                    animation, index) {
                                                  return SizedBox(
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 10),
                                                        Container(
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
                                                              studentName,
                                                              style: const TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                            Text(
                                                              studentSection,
                                                              style: const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      100,
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      15,
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      15),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  0.5,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  25,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                color: Colors.white,
                                                border: Border.all(width: 2),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            20,
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            20),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        Text(
                                                          snapshot
                                                              .child('date')
                                                              .value
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "GothamRnd"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 30,
                                                            left: 20),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .watch_later_outlined,
                                                          color: Colors.black,
                                                        ),
                                                        Text(
                                                          snapshot
                                                              .child('time')
                                                              .value
                                                              .toString(),
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "GothamRnd"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                              },
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
      ),
    );
  }
}

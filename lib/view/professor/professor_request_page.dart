import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../student/profile_controller.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final formKey = GlobalKey<FormState>();
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  bool isEmptyPending = true;
  String name = '';
  StreamSubscription<DatabaseEvent>? nameSubscription, emptyPendingSubscription;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    emptyPendingSubscription?.cancel();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Database reference and query for empty view
    DatabaseReference emptyPendingRef =
        FirebaseDatabase.instance.ref('appointments');
    Query emptyPendingRefQuery = emptyPendingRef
        .orderByChild('requestStatusProfessor')
        .startAt("$userID-PENDING")
        .endAt("$userID-PENDING\uf8ff");

    emptyPendingSubscription = emptyPendingRefQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyPending = false;
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
    DatabaseReference studentsRef = FirebaseDatabase.instance.ref('students/');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          return false; // Disable back button
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF274C77),
            title: const Text(
              "Requests",
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'GothamRnd',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF274C77),
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      // Set the background color of the box
                      // Set the border radius of the box
                    ),
                    child: const Divider(
                      color: Colors.white,
                      thickness: 1.5,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF274C77),
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      // Set the background color of the box
                      // Set the border radius of the box
                    ),
                    height: 10,
                  ),
                  SearchBox(onSearch: _handleSearch),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isEmptyPending)
                    const SizedBox(
                      // color: Colors.red,
                      height: 125,
                      child: Center(
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
                    ),
                  if (!isEmptyPending)
                    Expanded(
                      child: FirebaseAnimatedList(
                        padding: const EdgeInsets.only(bottom: 20),
                        query: appointmentsRef
                            .orderByChild('requestStatusProfessor')
                            .startAt("$userID-PENDING")
                            .endAt("$userID-PENDING\uf8ff"),
                        itemBuilder: (context, snapshot, animation, index) {
                          // Modify strings based on your needs
                          String studentName =
                              snapshot.child('studentName').value.toString();
                          String studentSection =
                              snapshot.child('section').value.toString();
                          String profID =
                              snapshot.child('professorID').value.toString();
                          String appointID =
                              snapshot.child('appointID').value.toString();
                          String studID =
                              snapshot.child("studentID").value.toString();
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
                          // Filter professors based on the entered name
                          if (name.isNotEmpty &&
                              !studentName
                                  .toLowerCase()
                                  .contains(name.toLowerCase())) {
                            return Container(); // Hide the professor card if it doesn't match the search criteria
                          }

                          return SizedBox(
                            height: 210,
                            child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Colors.white,
                                margin: const EdgeInsets.only(
                                  top: 20,
                                  left: 17,
                                  right: 17,
                                ),
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
                                                const SizedBox(width: 10),
                                                Container(
                                                  height: 60,
                                                  width: 60,
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
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      studentName,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              "GothamRnd"),
                                                    ),
                                                    Text(
                                                      studentSection,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
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

                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 10),
                                    //   child: Column(
                                    //     mainAxisAlignment: MainAxisAlignment.start,
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text(snapshot
                                    //           .child('studentName')
                                    //           .value
                                    //           .toString()),
                                    //       Text(snapshot.child('section').value.toString()),
                                    //     ],
                                    //   ),
                                    // ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              60),
                                      width: MediaQuery.of(context).size.width /
                                          1.25,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_month_outlined,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                snapshot
                                                    .child('date')
                                                    .value
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontFamily: "GothamRnd"),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.watch_later_outlined,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                snapshot
                                                    .child('time')
                                                    .value
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontFamily: "GothamRnd"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Modify button based on what you need

                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Accept button
                                          ElevatedButton.icon(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Color(0xFF6096BA)),
                                              fixedSize:
                                                  MaterialStatePropertyAll(
                                                      Size(100, 20)),
                                              shape: MaterialStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)))),
                                            ),
                                            icon: const Icon(Icons.check,
                                                size: 17, color: Colors.white),
                                            label: const Text(
                                              'Accept',
                                              style: TextStyle(fontSize: 9),
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Are you sure you want to accept this appointment?'),
                                                      actions: [
                                                        TextButton(
                                                          child: const Text(
                                                            'Confirm',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GothamRnd"),
                                                          ),
                                                          onPressed: () async {
                                                            await appointmentsRef
                                                                .child(
                                                                    appointID)
                                                                .update({
                                                              'requestStatusProfessor':
                                                                  "$profID-UPCOMING-$outputDate:$outputTime",
                                                              'status':
                                                                  "$studID-UPCOMING-$outputDate:$outputTime",
                                                              'requestStatus':
                                                                  "UPCOMING",
                                                              // 'profilePicStatus':
                                                            });
                                                            // ignore: use_build_context_synchronously
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GothamRnd"),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                          ),
                                          // Reschedule button
                                          ElevatedButton.icon(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Color(0xFF6096BA)),
                                              fixedSize:
                                                  MaterialStatePropertyAll(
                                                      Size(100, 20)),
                                              shape: MaterialStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)))),
                                            ),
                                            icon: const Icon(
                                                Icons.calendar_month,
                                                size: 17,
                                                color: Colors.white),
                                            label: const Text(
                                              'Reschedule',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontFamily: "GothamRnd"),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Form(
                                                    key: formKey,
                                                    child: AlertDialog(
                                                      titlePadding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      title: Container(
                                                        height: 70,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        color: const Color(
                                                            0xFF274C77),
                                                        child: const Text(
                                                          'Reschedule',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  "GothamRnd",
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const SizedBox(
                                                              height: 10),
                                                          const Column(
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  "Appointment Date:",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        "GothamRnd",
                                                                    color: Color(
                                                                        0xFF393838),
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _dateController,
                                                                  onTap:
                                                                      _showDatePicker,
                                                                  readOnly:
                                                                      true,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(10)),
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.black), //<-- SEE HERE
                                                                    ),
                                                                    hintText:
                                                                        'Select reschedule date',
                                                                    hintStyle: TextStyle(
                                                                        fontFamily:
                                                                            "GothamRnd",
                                                                        fontSize:
                                                                            12),
                                                                    helperStyle:
                                                                        TextStyle(
                                                                            fontFamily:
                                                                                "GothamRnd"),
                                                                  ),
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please enter a date';
                                                                    }
                                                                    return null; // Return null if there is no error
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          const Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              "Appointment Time:",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "GothamRnd",
                                                                color: Color(
                                                                    0xFF393838),
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      _timeController,
                                                                  onTap:
                                                                      _showTimePicker,
                                                                  readOnly:
                                                                      true,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(width: 1, color: Colors.black), //<-- SEE HERE
                                                                          ),
                                                                          hintText:
                                                                              'Select appointment time',
                                                                          hintStyle: TextStyle(
                                                                              fontFamily:
                                                                                  "GothamRnd",
                                                                              fontSize:
                                                                                  12),
                                                                          helperStyle:
                                                                              TextStyle(fontFamily: "GothamRnd")),
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
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
                                                          child: const Text(
                                                            'OK',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GothamRnd",
                                                                color: Color(
                                                                    0xFF6096BA)),
                                                          ),
                                                          onPressed: () async {
                                                            if (formKey
                                                                .currentState!
                                                                .validate()) {
                                                              await appointmentsRef
                                                                  .child(appointID
                                                                      .toString())
                                                                  .update({
                                                                "countered":
                                                                    "yes",
                                                                "requestStatusProfessor":
                                                                    "$profID-RESCHEDULE-$outputDate:$outputTime",
                                                                "counteredDate":
                                                                    _dateController
                                                                        .text,
                                                                "counteredTime":
                                                                    _timeController
                                                                        .text,
                                                                "requestStatus":
                                                                    "RESCHEDULE",
                                                              });

                                                              // ignore: use_build_context_synchronously
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "GothamRnd",
                                                                color: Color(
                                                                    0xFF6096BA)),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          // Reject button
                                          ElevatedButton.icon(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Color(0xFF6096BA)),
                                              fixedSize:
                                                  MaterialStatePropertyAll(
                                                      Size(80, 20)),
                                              shape: MaterialStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)))),
                                            ),
                                            icon: const Icon(
                                                Icons.clear_rounded,
                                                size: 17,
                                                color: Colors.white),
                                            label: const Text(
                                              'Reject',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontFamily: "GothamRnd"),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    String profNotes = '';

                                                    return Form(
                                                      key: formKey,
                                                      child: AlertDialog(
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        title: Container(
                                                          height: 70,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20),
                                                          color: const Color(
                                                              0xFF274C77),
                                                          child: const Text(
                                                            'State your reason.',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    "GothamRnd",
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                        content: TextFormField(
                                                          onChanged: (value) {
                                                            profNotes = value;
                                                          },
                                                          maxLines: null,
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          decoration:
                                                              const InputDecoration(
                                                            hintText:
                                                                'Enter your reason',
                                                            hintStyle: TextStyle(
                                                                fontFamily:
                                                                    "GothamRnd"),
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please enter a reason';
                                                            }
                                                            return null; // Return null if there is no error
                                                          },
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                              'OK',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                await appointmentsRef
                                                                    .child(appointID
                                                                        .toString())
                                                                    .update({
                                                                  'notes':
                                                                      profNotes,
                                                                  'requestStatusProfessor':
                                                                      "$profID-CANCELED-$outputDate:$outputTime",
                                                                  'status':
                                                                      "$studID-CANCELED-$outputDate:$outputTime",
                                                                  'requestStatus':
                                                                      "CANCELED",
                                                                });
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "GothamRnd"),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        },
                      ),
                    )
                ]),
          ),
        ),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchBox({required this.onSearch, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF274C77), // Set the background color of the box
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        // Set the border radius of the box
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width / 20,
            right: MediaQuery.of(context).size.width / 20),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(fontFamily: "GothamRnd", color: Colors.grey),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF6096BA),
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF274C77)),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}

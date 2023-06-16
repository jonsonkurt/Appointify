import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  String name = '';
  StreamSubscription<DatabaseEvent>? nameSubscription;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

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

    DatabaseReference appointmentsRef =
        FirebaseDatabase.instance.ref('appointments/');
    DatabaseReference studentsRef = FirebaseDatabase.instance.ref('students/');
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
                    "Ready for Your Appointment?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            Container(width: 600, height: 1, color: Colors.black),
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
            Flexible(
              // height: 350,
              // width: 500,
              child: ContainedTabBarView(
                tabs: const [
                  Text(
                    'Upcoming',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    'Completed',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    'Canceled',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
                tabBarProperties: TabBarProperties(
                  width: 360,
                  height: 50,
                  background: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9343),
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
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                ),
                views: [
                  // Tab for Upcoming
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SizedBox(
                      width: 350,
                      height: 600,
                      child: FirebaseAnimatedList(
                        query: appointmentsRef
                            .orderByChild('requestStatusProfessor')
                            .equalTo("$userID-UPCOMING"),
                        itemBuilder: (context, snapshot, animation, index) {
                          String studentName =
                              snapshot.child('studentName').value.toString();
                          String studentSection =
                              snapshot.child('section').value.toString();
                          String appointID =
                              snapshot.child('appointID').value.toString();
                          String professorID =
                              snapshot.child('professorID').value.toString();
                          String studentID =
                              snapshot.child('studentID').value.toString();

                          return SizedBox(
                              height: MediaQuery.of(context).size.height/3.5,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 30),
                                child: Card(

                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  color: Colors.grey,
                                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/20, right: MediaQuery.of(context).size.width/20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(height: 15),
                                      Flexible(
                                        child: FirebaseAnimatedList(
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
                                                            BorderRadius
                                                                .circular(100),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        studentName,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        studentSection,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black),
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
                                        width: 340,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 30, left: 20),
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
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 30, left: 20),
                                              child: Row(
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
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.calendar_month,
                                                    size: 15,
                                                    color: Colors.white),
                                                label: const Text(
                                                  'Reschedule',
                                                  style: TextStyle(fontSize: 9),
                                                ),
                                                style: const ButtonStyle(
                                                  fixedSize:
                                                      MaterialStatePropertyAll(
                                                          Size(100, 20)),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color(
                                                        0xFFFF9343), // card button color
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // Handle button press
                                                  // Add your desired functionality here
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Reschedule'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        _dateController,
                                                                    onTap:
                                                                        _showDatePicker,
                                                                    readOnly:
                                                                        true,
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Select appointment date',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        _timeController,
                                                                    onTap:
                                                                        _showTimePicker,
                                                                    readOnly:
                                                                        true,
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      labelText:
                                                                          'Select appointment time',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                'OK'),
                                                            onPressed:
                                                                () async {
                                                              await appointmentsRef
                                                                  .child(appointID
                                                                      .toString())
                                                                  .update({
                                                                "countered":
                                                                    "yes",
                                                                "requestStatusProfessor":
                                                                    "$professorID-RESCHEDULE",
                                                                "counteredDate":
                                                                    _dateController
                                                                        .text,
                                                                "counteredTime":
                                                                    _timeController
                                                                        .text,
                                                                "status":
                                                                    '$studentID-PENDING',
                                                                "requestStatus":
                                                                    'PENDING'
                                                              });

                                                              // ignore: use_build_context_synchronously
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                'Cancel'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                // child: const Text('Reschedule'),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                                height:
                                                    75, // gap between the button and the info
                                              ),
                                              ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.cancel_outlined,
                                                    size: 15,
                                                    color: Colors.white),
                                                label: const Text('Cancel',
                                                    style:
                                                        TextStyle(fontSize: 9)),
                                                style: const ButtonStyle(
                                                  fixedSize:
                                                      MaterialStatePropertyAll(
                                                          Size(90, 20)),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color(
                                                        0xFFFF9343), // card button color
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        String profNotes = '';

                                                        return AlertDialog(
                                                          title: const Text(
                                                              'State your reason.'),
                                                          content: TextField(
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
                                                                  'Enter your paragraph',
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'OK'),
                                                              onPressed:
                                                                  () async {
                                                                await appointmentsRef
                                                                    .child(appointID
                                                                        .toString())
                                                                    .update({
                                                                  'notes':
                                                                      profNotes,
                                                                  'requestStatusProfessor':
                                                                      "$professorID-CANCELED",
                                                                  'status':
                                                                      "$studentID-CANCELED",
                                                                  'requestStatus':
                                                                      "CANCELED",
                                                                });
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancel'),
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
                                                // child: const Text('Cancel'),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.check,
                                                    size: 15,
                                                    color: Colors.white),
                                                label: const Text('Complete',
                                                    style:
                                                        TextStyle(fontSize: 9)),
                                                style: const ButtonStyle(
                                                  fixedSize:
                                                      MaterialStatePropertyAll(
                                                          Size(100, 20)),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color(
                                                        0xFFFF9343), // card button color
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // Handle button press
                                                  // Add your desired functionality here
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        String profNotes = '';

                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Are you sure you want to mark this appointment as completed?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Confirm'),
                                                              onPressed:
                                                                  () async {
                                                                await appointmentsRef
                                                                    .child(appointID
                                                                        .toString())
                                                                    .update({
                                                                  'requestStatusProfessor':
                                                                      "$professorID-COMPLETED",
                                                                  'status':
                                                                      "$studentID-COMPLETED",
                                                                  'requestStatus':
                                                                      "COMPLETED",
                                                                });
                                                                // ignore: use_build_context_synchronously
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancel'),
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
                                                // child: const Text('Completed'),
                                              ),
                                            ],
                                          )
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      width: 350,
                      height: 600,
                      child: FirebaseAnimatedList(
                        query: appointmentsRef
                            .orderByChild('requestStatusProfessor')
                            .equalTo("$userID-COMPLETED"),
                        itemBuilder: (context, snapshot, animation, index) {
                          String studentName =
                              snapshot.child('studentName').value.toString();
                          String studentSection =
                              snapshot.child('section').value.toString();
                          return SizedBox(
                              height: 140,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Card(
                                  
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  color: Colors.grey,
                                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/20, right: MediaQuery.of(context).size.width/20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(height: 15),
                                      Flexible(
                                        child: FirebaseAnimatedList(
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
                                                            BorderRadius
                                                                .circular(100),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        studentName,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        studentSection,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black),
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
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        width: 340,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 30, left: 20),
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
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(
                                                  right: 30, left: 20),
                                              child: Row(
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
                                                        color: Colors.black),
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

                  // Tab for Canceled
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      width: 350,
                      height: 600,
                      child: FirebaseAnimatedList(
                        query: appointmentsRef
                            .orderByChild('requestStatusProfessor')
                            .equalTo("$userID-CANCELED"),
                        itemBuilder: (context, snapshot, animation, index) {
                          String studentName =
                              snapshot.child('studentName').value.toString();
                          String studentSection =
                              snapshot.child('section').value.toString();
                          return SizedBox(
                              height: 225,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  color: Colors.grey,
                                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/20, right: MediaQuery.of(context).size.width/20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(height: 15),
                                      Flexible(
                                        child: FirebaseAnimatedList(
                                          query: studentsRef
                                              .orderByChild('$userID-CANCELED')
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
                                                            BorderRadius
                                                                .circular(100),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        studentName,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        studentSection,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black),
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
                                        width: 340,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 30, left: 20),
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
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 30, left: 20),
                                              child: Row(
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
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                                height:
                                                    75, // gap between the button and the info
                                              ),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.notes,
                                                    size: 15,
                                                    color: Colors.white),
                                                label: const Text('View notes',
                                                    style:
                                                        TextStyle(fontSize: 9)),
                                                style: const ButtonStyle(
                                                  fixedSize:
                                                      MaterialStatePropertyAll(
                                                          Size(100, 20)),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  )),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color(
                                                        0xFFFF9343), // card button color
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // Handle button press
                                                  // Add your desired functionality here
                                                },
                                                // child: const Text('Cancel'),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                            ],
                                          )
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

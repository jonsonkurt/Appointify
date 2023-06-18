import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:random_string/random_string.dart';

class ProfessorProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String professorRole;
  final String status;
  final String availability;
  final String professorID;
  final String salutation;

  const ProfessorProfilePage({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.professorRole,
    required this.status,
    required this.availability,
    required this.professorID,
    required this.salutation,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfessorProfilePageState createState() => _ProfessorProfilePageState();
}

class _ProfessorProfilePageState extends State<ProfessorProfilePage> {
  late Map<String, dynamic> myDictionary;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String resultText = '';
  String studname = "";
  String studLastName = '';
  String studSection = '';
  StreamSubscription<DatabaseEvent>? nameSubscription;
  StreamSubscription<DatabaseEvent>? getProfSnap;
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  String fcmProfToken = '';
  bool isLoading = true;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    myDictionary = parseStringToMap(widget.availability);
  }

  int _getWeekdayNumber(String weekday) {
    switch (weekday) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 0;
    }
  }

  Map<String, dynamic> parseStringToMap(String jsonString) {
    Map<String, dynamic> resultMap = {};

    String cleanedString = jsonString.replaceAll('{', '').replaceAll('}', '');

    List<String> keyValuePairs = cleanedString.split(',');

    for (String pair in keyValuePairs) {
      int colonIndex = pair.indexOf(':');
      String key = pair.substring(0, colonIndex).trim();
      String value = pair.substring(colonIndex + 1).trim();

      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }

      resultMap[key] = value;
    }

    return resultMap;
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) => Theme(
        data: ThemeData().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7778EE),
            onPrimary: Colors.grey,
            surface: Color(0xFFFF9343),
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
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
      builder: (BuildContext context, Widget? child) => Theme(
        data: ThemeData().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7778EE),
            onPrimary: Colors.grey,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.grey,
        ),
        child: child!,
      ),
    ).then((selectedTime) {
      if (selectedTime != null) {
        _timeController.text = selectedTime.format(context);
      }
    });
  }

  bool isTimeInRange(String selectedTime, String startTime, String endTime) {
    DateFormat dateFormat = DateFormat("hh:mm a");
    DateTime selectedDateTime = dateFormat.parse(selectedTime);
    DateTime startDateTime = dateFormat.parse(startTime);
    DateTime endDateTime = dateFormat.parse(endTime);
    return selectedDateTime.isAfter(startDateTime) &&
        selectedDateTime.isBefore(endDateTime);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  DatabaseReference refProf =
      FirebaseDatabase.instance.ref().child('professors');

  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );
    DatabaseReference nameRef = rtdb.ref().child('students/$userID/');
    nameSubscription = nameRef.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            studname = event.snapshot.child("firstName").value.toString();
            studLastName = event.snapshot.child("lastName").value.toString();
            studSection = event.snapshot.child("section").value.toString();
            isLoading = false;
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    getProfSnap = refProf.child(widget.professorID).onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            fcmProfToken =
                event.snapshot.child("fcmProfToken").value.toString();
            isLoading = false;
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });
    final String appointKey = randomAlphaNumeric(10);
    DatabaseReference appointmentsRef = rtdb.ref('appointments/$appointKey');
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 5,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 10,
                    bottom: -50,
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/default.jpg',
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 65),
                          Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Set an appointment',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "GothamRnd-Bold",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        indent: 30,
                        endIndent: 30,
                        thickness: 2,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 90,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: const TextStyle(
                          fontFamily: "GothamRnd-Bold",
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.professorRole,
                        style: const TextStyle(
                          fontFamily: "GothamRnd-Bold",
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    'Weekly Schedule',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "GothamRnd-Bold",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    for (var entry in myDictionary.entries.toList()
                      ..sort((a, b) => _getWeekdayNumber(a.key)
                          .compareTo(_getWeekdayNumber(b.key))))
                      if (entry.value != '-')
                        Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10, top: 10),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  color: Color(0xFF7778EE),
                                ),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(
                                  color: Colors
                                      .white, // Set the background color of the box
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  "${entry.value.split(' to ').join('\nto\n')}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    'Set an Appointment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "GothamRnd-Bold",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                              0xFF7778EE), // Replace with your desired color
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: const Color(0xFF7778EE),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Text(
                                    'Set Date :',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "GothamRnd-Light",
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: _dateController,
                                      onTap: _showDatePicker,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Date:',
                                        hintStyle: TextStyle(
                                          fontFamily: "GothamRnd-Italic",
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder
                                            .none, // Removes the border
                                        focusedBorder: InputBorder
                                            .none, // Removes the border when the TextField is focused
                                      ),
                                      style: const TextStyle(
                                        fontFamily: "GothamRnd-Light",
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                              0xFF7778EE), // Replace with your desired color
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: const Color(0xFF7778EE),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Text(
                                    'Choose Time :',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "GothamRnd-Light",
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD9D9D9),
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: _timeController,
                                      onTap: _showTimePicker,
                                      readOnly: true,
                                      style: const TextStyle(
                                        fontFamily: "GothamRnd-Light",
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Time:',
                                        hintStyle: TextStyle(
                                          fontFamily: "GothamRnd-Italic",
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder
                                            .none, // Removes the border
                                        focusedBorder: InputBorder
                                            .none, // Removes the border when the TextField is focused
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String selectedDate = _dateController.text;
                  String selectedTime = _timeController.text;
                  // change date to days
                  DateTime date = DateFormat('MMM d, yyyy').parse(selectedDate);
                  String dayOfWeek = DateFormat('EEEE').format(date);

                  for (var entry in myDictionary.entries) {
                    if (entry.key.startsWith(dayOfWeek)) {
                      String value = entry.value;

                      if (value == '-') {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text("The prof doesnt have this kind of sched"),
                        ));
                        break;
                      } else {
                        List<String> timeRange = value.split(' to ');
                        String startTime = timeRange[0];
                        String endTime = timeRange[1];

                        if (isTimeInRange(selectedTime, startTime, endTime)) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Set Appointment Done"),
                          ));
                          final fcmToken =
                              await FirebaseMessaging.instance.getToken();
                          String inputDate = selectedDate;
                          DateTime dateTime =
                              DateFormat('MMM dd, yyyy').parse(inputDate);
                          String outputDate =
                              DateFormat('MM-dd-yyyy').format(dateTime);
                          String inputTime = selectedTime;
                          DateTime time = DateFormat('h:mm a').parse(inputTime);
                          String outputTime = DateFormat('HH:mm').format(time);
                          await appointmentsRef.set({
                            "appointID": appointKey,
                            "countered": 'no',
                            "counteredDate": "",
                            "counteredTime": "",
                            "date": selectedDate,
                            "notes": "",
                            "professorID": widget.professorID,
                            "professorName":
                                "${widget.salutation} ${widget.firstName} ${widget.lastName}",
                            "professorRole": widget.professorRole,
                            "requestStatus": "PENDING",
                            "requestStatusProfessor":
                                "${widget.professorID}-PENDING-$outputDate:$outputTime",
                            "status": "$userID-PENDING-$outputDate:$outputTime",
                            "studentID": userID,
                            "studentName": "$studname $studLastName",
                            "section": studSection,
                            "time": selectedTime,
                            "fcmToken": fcmToken,
                            "fcmProfToken": fcmProfToken,
                          });
                          break;
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Not part of the schedule time"),
                          ));
                        }
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(155, 32),
                  backgroundColor: const Color(0xFFFF9343),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15), // Adjust the radius as needed
                  ),
                ),
                child: const Text(
                  'Confirm Schedule',
                  style: TextStyle(
                    fontFamily: "GothamRnd-Medium",
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

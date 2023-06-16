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
    DatabaseReference refProf =
        FirebaseDatabase.instance.ref().child('professors');
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
      body: Column(
        children: [
          IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          const Text('Set an appointment'),
          Image.asset('assets/images/default.jpg'),
          Text('${widget.firstName} ${widget.lastName}'),
          Text(widget.professorRole),
          Text(widget.status),
          for (var entry in myDictionary.entries)
            Text('${entry.key}: ${entry.value}'),
          const Divider(
            thickness: 3,
            color: Colors.black,
          ),
          TextField(
            controller: _dateController,
            onTap: _showDatePicker,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Select appointment date',
            ),
          ),
          TextField(
            controller: _timeController,
            onTap: _showTimePicker,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Select appointment time',
            ),
          ),
          ElevatedButton(
            child: const Text('Confirm Schedule'),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("The prof doesnt have this kind of sched"),
                    ));
                    break;
                  } else {
                    List<String> timeRange = value.split(' to ');
                    String startTime = timeRange[0];
                    String endTime = timeRange[1];

                    if (isTimeInRange(selectedTime, startTime, endTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Set Appointment Done"),
                      ));
                      final fcmToken =
                          await FirebaseMessaging.instance.getToken();
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
                            "${widget.professorID}-PENDING",
                        "status": "$userID-PENDING",
                        "studentID": userID,
                        "studentName": "$studname $studLastName",
                        "section": studSection,
                        "time": selectedTime,
                        "fcmToken": fcmToken,
                        "fcmProfToken": fcmProfToken,
                      });
                      break;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Not part of the schedule time"),
                      ));
                    }
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

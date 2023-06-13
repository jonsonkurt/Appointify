import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
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
    _dateController.dispose();
    _timeController.dispose();
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

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );

    DatabaseReference appointmentsRef = rtdb.ref('appointments/');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          const Text(
            'Requests',
          ),
          const Divider(
            color: Colors.black,
            thickness: 3,
          ),
          SearchBox(onSearch: _handleSearch),
          Expanded(
            child: FirebaseAnimatedList(
              query: appointmentsRef
                  .orderByChild('requestStatusProfessor')
                  .equalTo("$userID-PENDING"),
              itemBuilder: (context, snapshot, animation, index) {
                // Modify strings based on your needs
                String studentName =
                    snapshot.child('studentName').value.toString();
                String profID = snapshot.child('professorID').value.toString();
                String appointID = snapshot.child('appointID').value.toString();
                String studID = snapshot.child("studentID").value.toString();
                // Filter professors based on the entered name
                if (name.isNotEmpty &&
                    !studentName.toLowerCase().contains(name.toLowerCase())) {
                  return Container(); // Hide the professor card if it doesn't match the search criteria
                }

                return Card(
                    child: Column(
                  children: [
                    Text(snapshot.child('studentName').value.toString()),
                    Text(snapshot.child('section').value.toString()),
                    Text(snapshot.child('date').value.toString()),
                    Text(snapshot.child('time').value.toString()),

                    // Modify button based on what you need
                    ElevatedButton(
                      child: const Text('Accept'),
                      onPressed: () async {
                        await appointmentsRef.child(appointID).update({
                          'requestStatusProfessor': "$profID-UPCOMING",
                          'status': "$studID-UPCOMING",
                          'requestStatus': "UPCOMING",
                          // 'profilePicStatus':
                        });
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Reschedule'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Reschedule'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _dateController,
                                          onTap: _showDatePicker,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Select appointment date',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _timeController,
                                          onTap: _showTimePicker,
                                          readOnly: true,
                                          decoration: const InputDecoration(
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
                                  child: const Text('OK'),
                                  onPressed: () async {
                                    await appointmentsRef
                                        .child(appointID.toString())
                                        .update({
                                      "countered": "yes",
                                      "counteredDate": _dateController.text,
                                      "counteredTime": _timeController.text,
                                      "requestStatusProfessor":
                                          "$profID-RESCHEDULE"
                                    });

                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Reject'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String profNotes = '';

                              return AlertDialog(
                                title: const Text('State your reason.'),
                                content: TextField(
                                  onChanged: (value) {
                                    profNotes = value;
                                  },
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your paragraph',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () async {
                                      await appointmentsRef
                                          .child(appointID.toString())
                                          .update({
                                        'notes': profNotes,
                                        'requestStatusProfessor':
                                            "$profID-CANCELED",
                                        'status': "$studID-CANCELED",
                                        'requestStatus': "CANCELED",
                                      });
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                    )
                  ],
                ));
              },
            ),
          )
        ]),
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
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onSearch,
    );
  }
}

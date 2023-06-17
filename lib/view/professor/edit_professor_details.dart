import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'professor_profile_controller.dart';
import 'professor_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EditProfessorProfile extends StatefulWidget {
  const EditProfessorProfile({super.key});

  @override
  State<EditProfessorProfile> createState() => _EditProfessorProfileState();
}

class _EditProfessorProfileState extends State<EditProfessorProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final List<TimeOfDay?> _selectedFromTimes = List<TimeOfDay?>.filled(6, null);
  final List<TimeOfDay?> _selectedToTimes = List<TimeOfDay?>.filled(6, null);
  final bool val1 = true;

  final _formKey = GlobalKey<FormState>();

  String? userID = FirebaseAuth.instance.currentUser?.uid;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('professors');
  final List<String> schedStartTime = [];
  final List<String> schedEndTime = [];
  List<String> monday = [];
  List<String> tuesday = [];
  List<String> wednesday = [];
  List<String> thursday = [];
  List<String> friday = [];
  List<String> saturday = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getWeekdayNumber(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '-';
    }
  }

  Future<void> _selectFromTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedFromTimes[index] ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedFromTimes[index]) {
      setState(() {
        _selectedFromTimes[index] = picked;
      });
    } else {
      print('Canceled');
    }
  }

  Future<void> _selectToTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedToTimes[index] ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedToTimes[index]) {
      setState(() {
        _selectedToTimes[index] = picked;
      });
    }
  }

  String _getTime(int index) {
    TimeOfDay? fromTime = _selectedFromTimes[index];
    TimeOfDay? toTime = _selectedToTimes[index];

    if (fromTime != null && toTime != null) {
      String formattedFromTime = fromTime.format(context);
      String formattedToTime = toTime.format(context);

      String fromTimePeriod = formattedFromTime.contains('PM') ? 'PM' : 'AM';
      String toTimePeriod = formattedToTime.contains('PM') ? 'PM' : 'AM';

      // Remove the 'AM' or 'PM' from the formatted times
      formattedFromTime = formattedFromTime.replaceAll(RegExp(' (AM|PM)'), '');
      formattedToTime = formattedToTime.replaceAll(RegExp(' (AM|PM)'), '');

      return '$formattedFromTime $fromTimePeriod to $formattedToTime $toTimePeriod';
    } else {
      return '${schedStartTime[index]} to ${schedEndTime[index]}';
    }
  }

  List<String> extractTimes(String text) {
    final regex = RegExp(r'\d{1,2}:\d{2} (AM|PM)', caseSensitive: false);
    final matches = regex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
      create: (_) => ProfessorProfileController(),
      child: Consumer<ProfessorProfileController>(
          builder: (context, provider, child) {
        return SafeArea(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: StreamBuilder(
                  stream: ref.child(userID!.toString()).onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                      _firstNameController.text = map['firstName'];
                      _lastNameController.text = map['lastName'];
                      _phoneController.text = map['mobileNumber'];
                      _emailController.text = userEmail!;
                      _professionController.text = map['designation'];
                      Map<dynamic, dynamic> availability = map['availability'];

                      String dayOne = availability["Monday"];
                      String dayTwo = availability["Tuesday"];
                      String dayThree = availability["Wednesday"];
                      String dayFour = availability["Thursday"];
                      String dayFive = availability["Friday"];
                      String daySix = availability["Saturday"];
                      if (dayOne != "-") {
                        monday = extractTimes(dayOne);
                        schedStartTime.add(monday[0]);
                        schedEndTime.add(monday[1]);
                      } else {
                        schedStartTime.add("-");
                        schedEndTime.add("-");
                      }
                      if (dayTwo != "-") {
                        tuesday = extractTimes(dayTwo);
                        schedStartTime.add(tuesday[0]);
                        schedEndTime.add(tuesday[1]);
                      } else {
                        schedStartTime.add("-");
                        schedEndTime.add("-");
                      }
                      if (dayThree != "-") {
                        wednesday = extractTimes(dayThree);
                        schedStartTime.add(wednesday[0]);
                        schedEndTime.add(wednesday[1]);
                      } else {
                        schedStartTime.add("-");
                        schedEndTime.add("-");
                      }
                      if (dayFour != "-") {
                        thursday = extractTimes(dayFour);
                        schedStartTime.add(thursday[0]);
                        schedEndTime.add(thursday[1]);
                      } else {
                        schedStartTime.add("-");
                        schedEndTime.add("-");
                      }
                      if (dayFive != "-") {
                        friday = extractTimes(dayFive);
                        schedStartTime.add(friday[0]);
                        schedEndTime.add(friday[1]);
                      } else {
                        schedStartTime.add("-");
                        schedEndTime.add("-");
                      }

                      if (daySix != "-") {
                        saturday = extractTimes(daySix);
                        schedStartTime.add(saturday[0]);
                        schedEndTime.add(saturday[1]);
                      } else {
                        schedStartTime.add("-");
                        schedEndTime.add("-");
                      }

                      provider.imgURL = map['profilePicStatus'].toString();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(alignment: Alignment.bottomCenter, children: [
                            // Warning!!! Don't delete. This is edit picture
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                child: Container(
                                  height: 130,
                                  width: 130,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 35, 35, 35),
                                        width: 2,
                                      )),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: provider.image == null
                                          ? map['profilePicStatus']
                                                      .toString() ==
                                                  "None"
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 35,
                                                )
                                              : Image(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      provider.imgURL),
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return const CircularProgressIndicator();
                                                  },
                                                  errorBuilder:
                                                      (context, object, stack) {
                                                    return const Icon(
                                                      Icons.error_outline,
                                                      color: Color.fromARGB(
                                                          255, 35, 35, 35),
                                                    );
                                                  },
                                                )
                                          : Image.file(
                                              File(provider.image!.path)
                                                  .absolute)),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                provider.pickImage(context);
                              },
                              child: const CircleAvatar(
                                radius: 15,
                                child: Icon(Icons.edit, size: 15),
                              ),
                            )
                          ]),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30.0),
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                TextFormField(
                                  controller: _professionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Profession',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Profession';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email address';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                const Text("Weekly Schedule"),
                                Column(
                                  children: List.generate(6, (index) {
                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(_getWeekdayNumber(index + 1)),
                                            GestureDetector(
                                              onTap: () {
                                                _selectFromTime(context, index);
                                                setState(() {
                                                  final format =
                                                      DateFormat.jm();
                                                  String test = DateFormat.jm()
                                                      .format(DateTime.now());
                                                  String timeString =
                                                      schedStartTime[index] ==
                                                              "-"
                                                          ? test
                                                          : schedStartTime[
                                                              index];

                                                  final parsedTime =
                                                      format.parse(timeString);
                                                  final timeOfDay =
                                                      TimeOfDay.fromDateTime(
                                                          parsedTime);
                                                  _selectedFromTimes[index] =
                                                      timeOfDay;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 20),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  _selectedFromTimes[index] !=
                                                          null
                                                      ? _selectedFromTimes[
                                                              index]!
                                                          .format(context)
                                                      : schedStartTime[index],
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                            // GestureDetector(
                                            //   onTap: () => _selectFromTime(
                                            //       context, index),
                                            //   child: Container(
                                            //     padding:
                                            //         const EdgeInsets.symmetric(
                                            //             vertical: 10,
                                            //             horizontal: 20),
                                            //     decoration: BoxDecoration(
                                            //       border: Border.all(
                                            //           color: Colors.grey),
                                            //       borderRadius:
                                            //           BorderRadius.circular(5),
                                            //     ),
                                            //     child: Text(
                                            //       _selectedFromTimes[index] !=
                                            //               null
                                            //           ? _selectedFromTimes[
                                            //                   index]!
                                            //               .format(context)
                                            //           : "${schedStartTime[index]}",
                                            //       style: const TextStyle(
                                            //           fontSize: 16),
                                            //     ),
                                            //   ),
                                            // ),
                                            const Text(
                                              'To',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                _selectToTime(context, index);
                                                setState(() {
                                                  final format =
                                                      DateFormat.jm();
                                                  String test = DateFormat.jm()
                                                      .format(DateTime.now());
                                                  String timeString =
                                                      schedStartTime[index] ==
                                                              "-"
                                                          ? test
                                                          : schedStartTime[
                                                              index];
                                                  final parsedTime =
                                                      format.parse(timeString);
                                                  final timeOfDay =
                                                      TimeOfDay.fromDateTime(
                                                          parsedTime);
                                                  _selectedToTimes[index] =
                                                      timeOfDay;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 20),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  _selectedToTimes[index] !=
                                                          null
                                                      ? _selectedToTimes[index]!
                                                          .format(context)
                                                      : schedEndTime[index],
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // ElevatedButton(
                                        //   onPressed: () =>
                                        //       print(_getTime(index)),
                                        //   child: Text(
                                        //       'Print Pair ${index + 1} Time'),
                                        // ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  }),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    //print("${_getTime(0)} ");
                                    if (_formKey.currentState!.validate()) {
                                      await ref
                                          .child(userID.toString())
                                          .update({
                                        'profilePicStatus': provider.imgURL,
                                        "mobileNumber": _phoneController.text,
                                        "availability": {
                                          "Monday": _getTime(0),
                                          "Tuesday": _getTime(1),
                                          "Wednesday": _getTime(2),
                                          "Thursday": _getTime(3),
                                          "Friday": _getTime(4),
                                          "Saturday": _getTime(5),
                                        }
                                      });
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfessorProfilePage()),
                                      );
                                      _phoneController.clear();
                                      _emailController.clear();
                                    }
                                  },
                                  child: const Text('Confirm'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfessorProfilePage()),
                                    );
                                    _phoneController.clear();
                                    _emailController.clear();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: Text('Something went wrong.'));
                    }
                  }),
            ),
          ),
        ));
      }),
    ));
  }
}

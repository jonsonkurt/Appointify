import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'professor_profile_controller.dart';
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
  final List<bool?> _checkboxValues = List.generate(6, (index) => true);
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
    );
    if (picked != null && picked != _selectedFromTimes[index]) {
      setState(() {
        _selectedFromTimes[index] = picked;
      });
    } else {}
  }

  Future<void> _selectToTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedToTimes[index] ?? TimeOfDay.now(),
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
                      children: [
                        Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height / 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF9343),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0),
                                  ),
                                ),
                              ),
                              // Warning!!! Don't delete. This is edit picture
                              Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height /
                                        50),
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
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return const CircularProgressIndicator();
                                                    },
                                                    errorBuilder: (context,
                                                        object, stack) {
                                                      return const Icon(
                                                        Icons.error_outline,
                                                        color: Color.fromARGB(
                                                            255, 35, 35, 35),
                                                      );
                                                    },
                                                  )
                                            : Image.file(
                                                fit: BoxFit.cover,
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
                        const SizedBox(
                          height: 25,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Personal Information",
                              style: TextStyle(
                                fontFamily: "GothamRnd",
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 15.0),
                                TextFormField(
                                  controller: _firstNameController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(20.0),
                                    hintText: 'Enter your Name',
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Name';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 15.0),
                                TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Professor',
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your professor name';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 15.0),
                                TextFormField(
                                  controller: _professionController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 2.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Profession';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  "Weekly Schedule",
                                  style: TextStyle(
                                      fontFamily: 'GothamRnd',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.none),
                                ),
                                const SizedBox(height: 16.0),
                                Column(
                                  children: List.generate(6, (index) {
                                    bool isChecked =
                                        _checkboxValues[index] ?? false;
                                    Color containerColor =
                                        isChecked ? Colors.black : Colors.grey;
                                    Color textColor =
                                        isChecked ? Colors.black : Colors.grey;

                                    return Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Checkbox(
                                              value: schedStartTime[index] !=
                                                      '-'
                                                  ? (_checkboxValues[index] ??
                                                      true)
                                                  : false,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  print(newValue);
                                                  if (schedStartTime[index] !=
                                                      '-') {
                                                    _checkboxValues[index] =
                                                        newValue;
                                                  } else {
                                                    schedStartTime[index] =
                                                        "6:00 AM";
                                                    schedEndTime[index] =
                                                        "5:00 PM";
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              _getWeekdayNumber(index + 1)
                                                  .substring(0, 3)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontFamily: 'GothamRnd',
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            IgnorePointer(
                                              ignoring: !isChecked,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _selectFromTime(
                                                      context, index);
                                                  setState(() {
                                                    final format =
                                                        DateFormat.jm();
                                                    String test =
                                                        DateFormat.jm().format(
                                                            DateTime.now());

                                                    final parsedTime =
                                                        format.parse(test);
                                                    final timeOfDay =
                                                        TimeOfDay.fromDateTime(
                                                            parsedTime);
                                                    _selectedFromTimes[index] =
                                                        timeOfDay;
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: containerColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    _selectedFromTimes[index] !=
                                                            null
                                                        ? _selectedFromTimes[
                                                                index]!
                                                            .format(context)
                                                        : schedStartTime[index],
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 16,
                                                      fontFamily: 'GothamRnd',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              '-',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            IgnorePointer(
                                              ignoring: !isChecked,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _selectToTime(context, index);
                                                  setState(() {
                                                    final format =
                                                        DateFormat.jm();
                                                    String test =
                                                        DateFormat.jm().format(
                                                            DateTime.now());

                                                    final parsedTime =
                                                        format.parse(test);
                                                    final timeOfDay =
                                                        TimeOfDay.fromDateTime(
                                                            parsedTime);
                                                    _selectedToTimes[index] =
                                                        timeOfDay;
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: containerColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    _selectedToTimes[index] !=
                                                            null
                                                        ? _selectedToTimes[
                                                                index]!
                                                            .format(context)
                                                        : schedEndTime[index],
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 16,
                                                      fontFamily: 'GothamRnd',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(155, 32),
                                    backgroundColor: const Color(0xFF7778EE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Adjust the radius as needed
                                    ),
                                  ),
                                  onPressed: () async {
                                    print(_selectedFromTimes[0]);
                                    if (_formKey.currentState!.validate()) {
                                      await ref
                                          .child(userID.toString())
                                          .update({
                                        'profilePicStatus': provider.imgURL,
                                        "mobileNumber": _phoneController.text,
                                        "availability": {
                                          "Monday": _checkboxValues[0] == true
                                              ? _getTime(0) == '- to -'
                                                  ? '-'
                                                  : _getTime(0)
                                              : "-",
                                          "Tuesday": _checkboxValues[1] == true
                                              ? _getTime(1) == '- to -'
                                                  ? '-'
                                                  : _getTime(1)
                                              : "-",
                                          "Wednesday":
                                              _checkboxValues[2] == true
                                                  ? _getTime(2) == '- to -'
                                                      ? '-'
                                                      : _getTime(2)
                                                  : "-",
                                          "Thursday": _checkboxValues[3] == true
                                              ? _getTime(3) == '- to -'
                                                  ? '-'
                                                  : _getTime(3)
                                              : "-",
                                          "Friday": _checkboxValues[4] == true
                                              ? _getTime(4) == '- to -'
                                                  ? '-'
                                                  : _getTime(4)
                                              : "-",
                                          "Saturday": _checkboxValues[5] == true
                                              ? _getTime(5) == '- to -'
                                                  ? '-'
                                                  : _getTime(5)
                                              : "-",
                                        }
                                      });
                                      // ignore: use_build_context_synchronously

                                      Navigator.of(context).pop();
                                      _firstNameController.clear();
                                      _lastNameController.clear();
                                      _phoneController.clear();
                                      _professionController.clear();
                                      _emailController.clear();
                                    }
                                  },
                                  child: const Text('Confirm'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(155, 32),
                                    backgroundColor: const Color(0xFFFF9343),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Adjust the radius as needed
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    _firstNameController.clear();
                                    _lastNameController.clear();
                                    _phoneController.clear();
                                    _professionController.clear();
                                    _emailController.clear();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('Something went wrong.'));
                  }
                }),
          ),
        ));
      }),
    ));
  }
}

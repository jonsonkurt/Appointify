import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:glass/glass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:logger/logger.dart';

import 'package:recase/recase.dart';
import 'edit_professor_details.dart';

class ProfessorProfilePage extends StatefulWidget {
  const ProfessorProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfessorProfilePage> createState() => _ProfessorProfilePageState();
}

class _ProfessorProfilePageState extends State<ProfessorProfilePage> {
  late Map<String, dynamic> profFullSched;
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('professors');
  bool status1 = true;
  StreamSubscription<DatabaseEvent>? nameSubscription;
  String name = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    DatabaseReference studRef =
        FirebaseDatabase.instance.ref().child('students');
    DatabaseReference profRef =
        FirebaseDatabase.instance.ref().child('professors');
    DatabaseReference desigRef =
        FirebaseDatabase.instance.ref().child('students/$userID/designation');

    nameSubscription = desigRef.onValue.listen((event) async {
      try {
        name = event.snapshot.value.toString();
        // ignore: unnecessary_null_comparison
        if (name == "Student") {
          await studRef.child(userID!).update({
            'fcmToken': "-",
          });
        } else {
          await profRef.child(userID!).update({
            'fcmProfToken': '-',
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    // Redirect the user to the SignInPage after logging out
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
            child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: StreamBuilder(
            stream: ref.child(userID!).onValue,
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                String firstName = map['firstName'];
                String lastName = map['lastName'];
                String mobileNumber = map['mobileNumber'];
                String designation = map['designation'];
                String profilePicStatus = map['profilePicStatus'].toString();
                String profSched = map['availability'].toString();
                profFullSched = parseStringToMap(profSched);

                return Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Image.network(
                              "https://lh3.googleusercontent.com/p/AF1QipMK9cNvGkzbzuAYcz3LP0WPUlkKCPh3yFa0dFhq=s1360-w1360-h1020",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: MediaQuery.of(context).size.width * .01,
                          top: MediaQuery.of(context).size.height * .008,
                          child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfessorProfile()),
                                );
                              },
                              icon: const Icon(
                                Icons.edit_note,
                                size: 40,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * .15),
                          child: Center(
                            child: Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 35, 35, 35),
                                    width: 2,
                                  )),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: map['profilePicStatus'].toString() ==
                                          "None"
                                      ? const Icon(
                                          Icons.person,
                                          size: 35,
                                        )
                                      : Image(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(profilePicStatus),
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
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
                                        )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              decoration: TextDecoration.none),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            designation,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                decoration: TextDecoration.none),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                "Availability Status:",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            FlutterSwitch(
                              activeColor: Colors.green,
                              value: status1,
                              height: 25.0,
                              width: 55,
                              borderRadius: 30.0,
                              onToggle: (val) {
                                setState(() {
                                  if (val == true) {
                                    status1 = val;
                                    ref.child(userID.toString()).update({
                                      "status": "accepting",
                                    });
                                  } else {
                                    status1 = val;
                                    ref.child(userID.toString()).update({
                                      "status": "not accepting",
                                    });
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 10, top: 10),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  color: Colors.green,
                                ),
                                child: const Text(
                                  "Email:",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  userEmail!,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 10, top: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  color: Colors.green,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Text(
                                  "Contact Number:",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  mobileNumber,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      decoration: TextDecoration.none),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, left: 20),
                      child: const Text(
                        "Weekly Schedule",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            decoration: TextDecoration.none),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var entry in profFullSched.entries.toList()
                            ..sort((a, b) => _getWeekdayNumber(a.key)
                                .compareTo(_getWeekdayNumber(b.key))))
                            if (entry.value != '-')
                              SizedBox(
                                child: Card(
                                  elevation: 8,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  color: Colors.white30,
                                  child: Column(
                                    children: [
                                      Container(
                                          alignment: Alignment.center,
                                          width: 140,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                          child: Text(
                                            entry.key,
                                          )),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${entry.value.split(' to ').join('\nto\n')}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Container(
                                      //   padding: EdgeInsets.all(10),
                                      //   alignment: Alignment.center,
                                      //   child: Text("${entry.value}")
                                      //   ),
                                    ],
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text("Logout"),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('Something went wrong.'));
              }
            }),
      ),
    )));
  }
}

class ReuseableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  const ReuseableRow(
      {super.key,
      required this.title,
      required this.value,
      required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: Icon(iconData),
          trailing: Text(value),
        ),
        const Divider(
          color: Color.fromARGB(255, 35, 35, 35),
        ),
      ],
    );
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

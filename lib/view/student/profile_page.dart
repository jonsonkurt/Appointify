import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';
import 'package:logger/logger.dart';

import 'edit_student_details.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');
  StreamSubscription<DatabaseEvent>? nameSubscription;
  String name = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    super.dispose();
  }

  _logout() async {
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

  @override
  Widget build(BuildContext context) {
    // final Storage storage = Storage();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                  String section = map['section'];
                  String email = map['email'];
                  String profilePicStatus = map['profilePicStatus'].toString();

                  return Column(children: [
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
                            child: const ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.all(15),
                              child: const Text(
                                "Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "GothamRnd",
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const Divider(
                              indent: 30,
                              endIndent: 30,
                              thickness: 2,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * .12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 110,
                                  width: 110,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                  ),
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
                                            image:
                                                NetworkImage(profilePicStatus),
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
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width / 2.5,
                          top: MediaQuery.of(context).size.height * .21,
                          child: Row(
                            children: [
                              Text(
                                firstName,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "GothamRnd",
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                lastName,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "GothamRnd",
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        // update prolife logic
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: "GothamRnd"),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFFF9343),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditStudentProfile()),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                )),
                          )
                        ]),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 10, top: 10),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    color: Color(0xFF7778EE),
                                  ),
                                  child: const Text(
                                    "Email:",
                                    style: TextStyle(
                                      fontFamily: "GothamRnd",
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    email,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontFamily: "GothamRnd",
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
                                    color: Color(0xFF7778EE),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: const Text(
                                    "Section:",
                                    style: TextStyle(
                                      fontFamily: "GothamRnd",
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    section,
                                    style: const TextStyle(
                                        fontFamily: "GothamRnd",
                                        fontSize: 15,
                                        color: Colors.black,
                                        decoration: TextDecoration.none),
                                  ),
                                )
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
                                    color: Color(0xFF7778EE),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: const Text(
                                    "Contact Number:",
                                    style: TextStyle(
                                      fontFamily: "GothamRnd",
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                        fontFamily: "GothamRnd",
                                        decoration: TextDecoration.none),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ReuseableRow(
                    //     title: 'Name',
                    //     value: '$firstName $lastName',
                    //     iconData: Icons.person_outline),
                    // ReuseableRow(
                    //     title: 'Email', value: email, iconData: Icons.email),
                    // ReuseableRow(
                    //     title: 'Phone',
                    //     value: mobileNumber,
                    //     iconData: Icons.phone),
                    // ReuseableRow(
                    //     title: 'Section',
                    //     value: section,
                    //     iconData: Icons.group),

                    //update profile button
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(
                                Color(0xFFFF9343)),
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        onPressed: _logout,
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "GothamRnd",
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ]);
                } else {
                  return const Center(
                      child: Text(
                    'Something went wrong.',
                    style: TextStyle(fontFamily: "GothamRnd"),
                  ));
                }
              }),
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
          title: Text(
            title,
            style: TextStyle(fontFamily: "GothamRnd"),
          ),
          leading: Icon(iconData),
          trailing: Text(
            value,
            style: TextStyle(fontFamily: "GothamRnd"),
          ),
        ),
        const Divider(
          color: Color.fromARGB(255, 35, 35, 35),
        ),
      ],
    );
  }
}

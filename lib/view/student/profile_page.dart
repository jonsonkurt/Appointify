import 'dart:async';
import 'package:appointify/image_viewer.dart';
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
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert), // Set the icon
                onSelected: (value) {
                  // Handle menu item selection here
                  if (value == 'option1') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditStudentProfile(),
                      ),
                    );
                  } else if (value == 'option2') {
                    // Do something for option 2
                    _logout();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'option1',
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: Colors.black,
                          ), // Icon for Option 1
                          SizedBox(width: 8), // Add some spacing
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontFamily: 'GothamRnd',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'option2',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.black,
                          ), // Icon for Option 2
                          SizedBox(width: 8), // Add some spacing
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontFamily: 'GothamRnd',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                })
          ],
          backgroundColor: const Color(0xFF274C77),
          title: const Text(
            "Profile",
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'GothamRnd',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
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
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF274C77),
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
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 30,
                              left: MediaQuery.of(context).size.height / 6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return DetailScreen(
                                        imageUrl: profilePicStatus,
                                        projectID: userID!,
                                      );
                                    }));
                                  },
                                  child: Hero(
                                    tag: userID!,
                                    child: Container(
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: map['profilePicStatus']
                                                    .toString() ==
                                                "None"
                                            ? const Icon(
                                                Icons.person,
                                                size: 35,
                                              )
                                            : Image(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    profilePicStatus),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 5),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "$firstName $lastName",
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.height / 25,
                              top: MediaQuery.of(context).size.height / 70),
                          child: const Text(
                            'Personal Information',
                            style: TextStyle(
                                fontFamily: "GothamRnd",
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ),
                        ),
                      ],
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
                                    color: Color(0xFF6096BA),
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
                                  padding: const EdgeInsets.all(10),
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
                                    color: Color(0xFF6096BA),
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
                                  padding: const EdgeInsets.all(10),
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
                                    color: Color(0xFF6096BA),
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
                                  padding: const EdgeInsets.all(10),
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

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

  @override
  Widget build(BuildContext context) {
    // final Storage storage = Storage();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                    String profilePicStatus =
                        map['profilePicStatus'].toString();

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Profile page Text
                          Container(
                              margin: const EdgeInsets.all(15),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                "Profile",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Container(
                                height: 130,
                                width: 130,
                                decoration: BoxDecoration(
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
                                          )),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // update prolife logic
                              children: [
                                const Text(
                                  "Edit Information",
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Colors.black,
                                      fontSize: 20),
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
                                      icon: const Icon(Icons.edit)),
                                )
                              ]),
                          ReuseableRow(
                              title: 'Name',
                              value: '$firstName $lastName',
                              iconData: Icons.person_outline),
                          ReuseableRow(
                              title: 'Email',
                              value: email,
                              iconData: Icons.email),
                          ReuseableRow(
                              title: 'Phone',
                              value: mobileNumber,
                              iconData: Icons.phone),
                          ReuseableRow(
                              title: 'Section',
                              value: section,
                              iconData: Icons.group),

                          //update profile button
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          Color(0xFFFF9343)),
                                  shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)))),
                              onPressed: _logout,
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ]);
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

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';

import 'edit_student_details.dart';
// import 'package:transparent_image/transparent_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

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
                          const Text("Profile"),
                          const SizedBox(
                            height: 20,
                          ),
                          Stack(alignment: Alignment.bottomCenter, children: [
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
                                            )),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            // update prolife logic
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditStudentProfile()),
                                );
                                // provider.pickImage(context);
                              },
                              child: const Text('Edit Personal Information'),
                            ),
                          ),
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

                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _logout,
                            child: const Text("Logout"),
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

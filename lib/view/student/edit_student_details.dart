import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_controller.dart';

class EditStudentProfile extends StatefulWidget {
  const EditStudentProfile({super.key});

  @override
  State<EditStudentProfile> createState() => _EditStudentProfileState();
}

class _EditStudentProfileState extends State<EditStudentProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _section = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? userID = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phone.dispose();
    _section.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
            create: (_) => ProfileController(),
            child: Consumer<ProfileController>(
                builder: (context, provider, child) {
              return SafeArea(
                  child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SingleChildScrollView(
                  child: StreamBuilder(
                      stream: ref.child(userID!.toString()).onValue,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasData) {
                          Map<dynamic, dynamic> map =
                              snapshot.data.snapshot.value;
                          String firstName = map['firstName'];
                          String lastName = map['lastName'];
                          _phone.text = map['mobileNumber'];
                          _section.text = map['section'];
                          provider.imgURL = map['profilePicStatus'].toString();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(clipBehavior: Clip.none, children: [
                                Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height / 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF274C77),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontFamily: 'GothamRnd',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height / 10,
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 110,
                                      width: 110,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
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
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          5,
                                      left: MediaQuery.of(context).size.height /
                                          7.5),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        provider.pickImage(context);
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Color(0xFF274C77),
                                        foregroundColor: Colors.white,
                                        radius: 15,
                                        child: Icon(Icons.edit, size: 15),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16.0),
                                    Text(
                                      '$firstName $lastName',
                                      style: const TextStyle(
                                          fontFamily: "GothamRnd",
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 15.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Mobile Number",
                                              style: TextStyle(
                                                fontFamily: "GothamRnd",
                                                color: Color(0xFF393838),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          child: TextFormField(
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: "GothamRnd"),
                                            controller: _phone,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(20.0),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color(0xFF274C77),
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your mobile number';
                                              }
                                              return null; // Return null if there is no error
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16.0),
                                    Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 15.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Section",
                                              style: TextStyle(
                                                fontFamily: "GothamRnd",
                                                color: Color(0xFF393838),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          child: TextFormField(
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: "GothamRnd"),
                                            controller: _section,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(20.0),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color(0xFF274C77),
                                                    width: 2.0),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter your section';
                                              }
                                              return null; // Return null if there is no error
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 25.0),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(130, 10),
                                        backgroundColor:
                                            const Color(0xFF274C77),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          await provider.updloadImage();
                                          await ref
                                              .child(userID.toString())
                                              .update({
                                            'mobileNumber': _phone.text,
                                            'section': _section.text,
                                          });
                                          if (provider.imgURL != "") {
                                            await ref
                                                .child(userID.toString())
                                                .update({
                                              'profilePicStatus':
                                                  provider.imgURL
                                            });
                                          }

                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(
                                            context,
                                          );
                                          _phone.clear();
                                          _section.clear();
                                        }
                                      },
                                      child: const Text(
                                        'Confirm',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: "GothamRnd",
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(130, 10),
                                        backgroundColor:
                                            const Color(0xFF6096BA),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _phone.clear();
                                        _section.clear();
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: "GothamRnd",
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                              child: Text('Something went wrong.',
                                  style: TextStyle(fontFamily: "GothamRnd")));
                        }
                      }),
                ),
              ));
            })));
  }
}

import 'dart:io';

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
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _section = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? userID = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('professors');

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
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
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
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasData) {
                          Map<dynamic, dynamic> map =
                              snapshot.data.snapshot.value;
                          String firstName = map['firstName'];
                          String lastName = map['lastName'];
                          String designation = map['designation'];
                          String professorRole = map['professorRole'];
                          String salutation = map['salutation'];
                          provider.imgURL = map['profilePicStatus'].toString();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
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
                                                          errorBuilder:
                                                              (context, object,
                                                                  stack) {
                                                            return const Icon(
                                                              Icons
                                                                  .error_outline,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      35,
                                                                      35,
                                                                      35),
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
                              // ElevatedButton(
                              //   onPressed: () {
                              //     provider.pickImage(context);
                              //   },
                              //   child: const Text('Select photo'),
                              // ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16.0),
                                    Text('$firstName $lastName'),
                                    const SizedBox(height: 16.0),
                                    TextFormField(
                                      controller: _phone,
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
                                      controller: _section,
                                      decoration: const InputDecoration(
                                        labelText: 'Section',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your section';
                                        }
                                        return null; // Return null if there is no error
                                      },
                                    ),
                                    const SizedBox(height: 16.0),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          await ref
                                              .child(userID.toString())
                                              .update({
                                            // 'mobileNumber': _phone.text,
                                            // 'section': _section.text,
                                            'profilePicStatus': provider.imgURL
                                          });
                                          // ignore: use_build_context_synchronously
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ProfessorProfilePage()),
                                          );
                                          _phone.clear();
                                          _section.clear();
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
                                        _phone.clear();
                                        _section.clear();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Center(
                              child: Text('Something went wrong.'));
                        }
                      }),
                ),
              ),
            ));
          }),
        ));
  }
}

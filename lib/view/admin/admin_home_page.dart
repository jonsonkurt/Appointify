import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  State<HomePageAdmin> createState() => _HomePageStateAdmin();
}

class _HomePageStateAdmin extends State<HomePageAdmin> {
  var logger = Logger();
  // String realTimeValue = "";
  // String? userID = FirebaseAuth.instance.currentUser?.uid;
  // bool isLoading = true;
  // String name = '';
  // StreamSubscription<DatabaseEvent>? nameSubscription;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    _firstNameController.addListener(() {});
  }

  @override
  void dispose() {
    // nameSubscription?.cancel();
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );

    // DatabaseReference nameRef = rtdb.ref().child('students/$userID/firstName');
    // nameSubscription = nameRef.onValue.listen((event) {
    //   try {
    //     if (mounted) {
    //       setState(() {
    //         name = event.snapshot.value.toString();
    //         isLoading = false;
    //       });
    //     }
    //   } catch (error, stackTrace) {
    //     logger.d('Error occurred: $error');
    //     logger.d('Stack trace: $stackTrace');
    //   }
    // });

    // DatabaseReference appointmentsRef = rtdb.ref('appointments/');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet<dynamic>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  return null; // Return null if there is no error
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
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
                                    return 'Please enter a valid email';
                                  } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null; // Return null if there is no error
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null; // Return null if there is no error
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _conpasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null; // Return null if there is no error
                                },
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Perform sign in logic here
                                    String firstName =
                                        _firstNameController.text;
                                    String lastName = _lastNameController.text;
                                    String email = _emailController.text;
                                    String password = _passwordController.text;

                                    try {
                                      // ignore: unused_local_variable
                                      final credential = await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );

                                      String? userID = FirebaseAuth
                                          .instance.currentUser?.uid;

                                      await rtdb.ref("professors/$userID").set({
                                        "firstName": firstName,
                                        "lastName": lastName,
                                        "profUserID": userID,
                                        "professorRole": "Professor",
                                        "salutation": email,
                                        "status": "accepting",
                                      });

                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);

                                      _firstNameController.text = "";
                                      _lastNameController.text = "";
                                      _emailController.text = "";
                                      _passwordController.text = "";
                                      _conpasswordController.text = "";
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == 'weak-password') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'The password provided is too weak.')),
                                        );
                                      } else if (e.code ==
                                          'email-already-in-use') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'The account already exists for that email.')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(content: Text('Error.')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Create Account'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      // ),
                      // ),
                    );
                  },
                );
              },
              label: const Text('Create Account'),
              icon: const Icon(Icons.thumb_up),
              backgroundColor: Colors.pink,
            ),

            // Text("Hi, I'm Admin"),
            // Expanded(
            //   child: FirebaseAnimatedList(
            //     query: appointmentsRef
            //         .orderByChild('studentUserID')
            //         .equalTo(userID),
            //     itemBuilder: (context, snapshot, animation, index) {
            //       return Card(
            //           child: Column(
            //         children: [
            //           Text(
            //             snapshot.child('professorName').value.toString(),
            //           ),
            //           Text(
            //             snapshot.child('professorRole').value.toString(),
            //           ),
            //           Text(
            //             snapshot.child('date').value.toString(),
            //           ),
            //           Text(
            //             snapshot.child('time').value.toString(),
            //           ),
            //         ],
            //       ));
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

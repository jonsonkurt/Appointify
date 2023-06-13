import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:appointify/view/student/profile_controller.dart';

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
  final bool _isObscure = true;
  String name = '';

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

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
    DatabaseReference professorRef = rtdb.ref('professors/');

    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: const Text("List of Employees", style: TextStyle(color: Colors.black),),
          elevation: 0,
          backgroundColor: Colors.white12,
          titleTextStyle: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: Column(
          children: [
            SearchBox(
              onSearch: _handleSearch,
            ),
            Expanded(
                child: FirebaseAnimatedList(
                    query: professorRef,
                    itemBuilder: (context, snapshot, animation, index) {
                      String profFirstName =
                          snapshot.child('firstName').value.toString();
                      String profLastName =
                          snapshot.child('lastName').value.toString();

                      // Filter professors based on the entered name

                      if (name.isNotEmpty &&
                          !profFirstName
                              .toLowerCase()
                              .contains(name.toLowerCase()) &&
                          !profLastName
                              .toLowerCase()
                              .contains(name.toLowerCase())) {
                        return Container(); // Hide the professor card if it doesn't match the search criteria
                      }
                      return Card(
                        child: Column(
                          children: [
                            Center(
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
                                    child: ProfileController().image == null
                                        ? snapshot
                                                    .child('profilePicStatus')
                                                    .value
                                                    .toString() ==
                                                "None"
                                            ? const Icon(
                                                Icons.person,
                                                size: 35,
                                              )
                                            : Image(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(snapshot
                                                    .child('profilePicStatus')
                                                    .value
                                                    .toString()),
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
                                              )
                                        : Image.file(File(
                                                ProfileController().image!.path)
                                            .absolute)),
                              ),
                            ),
                            Text("$profFirstName $profLastName"),
                            Text(snapshot
                                .child('professorRole')
                                .value
                                .toString()),
                            const Text("HINDI KO ALAM ANO NEED DITO"),
                            const Text("Status: Employee"),
                          ],
                        ),
                      );
                    }))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet<dynamic>(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25.0))),
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                    padding: EdgeInsets.only(
                        top: 20,
                        right: 20,
                        left: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Wrap(
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
                                obscureText: _isObscure,
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
                                obscureText: _isObscure,
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
                                        "salutation": "",
                                        "status": "accepting",
                                        "designation": "Professor",
                                        "profilePicStatus": "None",
                                        "availability": {
                                          "Monday": "-",
                                          "Tuesday": "-",
                                          "Wednesday": "-",
                                          "Thursday": "-",
                                          "Friday": "-",
                                          "Saturday": "-",
                                          "Sunday": "-",
                                        }
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
                        const SizedBox(height: 20),
                      ],
                      // ),
                      // ),
                    )

                    // },
                    ));
          },
          label: const Text('Create Account'),
          icon: const Icon(Icons.add),
          backgroundColor: Color(0xFFFF9343),
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
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchBox({required this.onSearch, Key? key}) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search...',
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xffFF9343),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(20),
            )),
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}

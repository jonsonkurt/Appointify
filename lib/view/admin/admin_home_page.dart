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
    FirebaseDatabase.instance.ref('organizationChart/null').set({
      'name': "-",
      'position1': "test",
    });
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
    DatabaseReference professorRef =
        FirebaseDatabase.instance.ref('professors/');

    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 50,
                  bottom: MediaQuery.of(context).size.width / 100,
                  left: MediaQuery.of(context).size.width / 15,
                  right: MediaQuery.of(context).size.width / 30,
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "List of Employees",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontFamily: "GothamRnd",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 10),
            Container(width: 350, height: 1, color: Colors.black),
            const SizedBox(height: 10),
            SearchBox(
              onSearch: _handleSearch,
            ),
            const SizedBox(height: 15),
            Expanded(
                child: FirebaseAnimatedList(
                    padding: const EdgeInsets.only(bottom: 60),
                    query: professorRef,
                    itemBuilder: (context, snapshot, animation, index) {
                      String profUserID =
                          snapshot.child('profUserID').value.toString();
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
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(
                            top: 10,
                            left: 30,
                            right: 30,
                          ),
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA2C2FF),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: ProfileController().image == null
                                            ? snapshot
                                                        .child(
                                                            'profilePicStatus')
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
                                                        .child(
                                                            'profilePicStatus')
                                                        .value
                                                        .toString()),
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
                                            : Image.file(File(
                                                    ProfileController()
                                                        .image!
                                                        .path)
                                                .absolute)),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 5),
                                        child: Text(
                                          "$profFirstName $profLastName",
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontFamily: "GothamRnd",
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        snapshot
                                            .child('professorRole')
                                            .value
                                            .toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: const TextStyle(
                                            fontFamily: "GothamRnd-Light",
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        // Show a confirmation dialog before deleting the employee
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete this employee?'),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Delete'),
                                                  onPressed: () async {
                                                    // Perform the deletion logic here
                                                    // TODO: Add your logic for deleting the employee

                                                    await professorRef
                                                        .child(profUserID)
                                                        .update({
                                                      "employmentStatus":
                                                          "Resigned",
                                                    });

                                                    // ignore: use_build_context_synchronously
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog after deleting
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15,
                                )
                              ]),
                            ],
                          ),
                        ),
                      );
                    })),
            const SizedBox(height: 15),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet<dynamic>(
              backgroundColor: const Color(0xFFF2F2F2),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              context: context,
              isScrollControlled: true,
              builder: (context) => LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 150,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          right: 20,
                          left: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom +
                              MediaQuery.of(context).size.height / 15,
                        ),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: <Widget>[
                            Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Stack(children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Create Account",
                                            style: TextStyle(
                                              fontFamily: "GothamRnd-Bold",
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 25),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "First Name",
                                          style: TextStyle(
                                            fontFamily: "GothamRnd",
                                            color: Color(0xFF393838),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _firstNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your first name';
                                            }
                                            return null; // Return null if there is no error
                                          },
                                        ),
                                        const SizedBox(height: 8.0),
                                        const Text(
                                          "Last Name",
                                          style: TextStyle(
                                            fontFamily: "GothamRnd",
                                            color: Color(0xFF393838),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _lastNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your last name';
                                            }
                                            return null; // Return null if there is no error
                                          },
                                        ),
                                        const SizedBox(height: 8.0),
                                        const Text(
                                          "Email Address",
                                          style: TextStyle(
                                            fontFamily: "GothamRnd",
                                            color: Color(0xFF393838),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a valid email';
                                            } else if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid email';
                                            }
                                            return null; // Return null if there is no error
                                          },
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 8.0),
                                        const Text(
                                          "Password",
                                          style: TextStyle(
                                            fontFamily: "GothamRnd-Medium",
                                            color: Color(0xFF393838),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _isObscure,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a password';
                                            }
                                            return null; // Return null if there is no error
                                          },
                                        ),
                                        const SizedBox(height: 8.0),
                                        const Text(
                                          "Confirm Password",
                                          style: TextStyle(
                                            fontFamily: "GothamRnd-Medium",
                                            color: Color(0xFF393838),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: _conpasswordController,
                                          obscureText: _isObscure,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please confirm your password';
                                            }
                                            if (value !=
                                                _passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null; // Return null if there is no error
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20.0),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(203, 50),
                                        backgroundColor:
                                            const Color(0xFF274C77),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Perform sign in logic here
                                          String firstName =
                                              _firstNameController.text;
                                          String lastName =
                                              _lastNameController.text;
                                          String email = _emailController.text;
                                          String password =
                                              _passwordController.text;

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

                                            await professorRef
                                                .child("/$userID")
                                                .set({
                                              "firstName": firstName,
                                              "lastName": lastName,
                                              "profUserID": userID,
                                              "mobileNumber": "-",
                                              "professorRole": "Employee",
                                              "employmentStatus": "Employed",
                                              "salutation": "",
                                              "status": "accepting",
                                              "designation": "Professor",
                                              "profilePicStatus": "None",
                                              "fcmProfToken": "-",
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
                                                  'The account already exists for that email.',
                                                  style: TextStyle(
                                                      fontFamily: "GothamRnd"),
                                                )),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                'Error.',
                                                style: TextStyle(
                                                    fontFamily: "GothamRnd"),
                                              )),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontFamily: "GothamRnd",
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
            //   showModalBottomSheet<dynamic>(
            //     backgroundColor: const Color(0xFFF2F2F2),
            //     shape: const RoundedRectangleBorder(
            //         borderRadius:
            //             BorderRadius.vertical(top: Radius.circular(25.0))),
            //     context: context,
            //     isScrollControlled: true,
            //     builder: (context) => SingleChildScrollView(
            //       child: Padding(
            //           padding: EdgeInsets.only(
            //               top: 20,
            //               right: 20,
            //               left: 20,
            //               bottom: MediaQuery.of(context).size.height / 15),
            //           child: Wrap(
            //             spacing: 8.0, // gap between adjacent chips
            //             runSpacing: 4.0, // gap between lines
            //             children: <Widget>[
            //               Form(
            //                 key: _formKey,
            //                 child: SingleChildScrollView(
            //                   child: Column(
            //                     mainAxisAlignment: MainAxisAlignment.start,
            //                     children: [
            //                       const Stack(children: [
            //                         Padding(
            //                           padding: EdgeInsets.only(
            //                             top: 10,
            //                           ),
            //                           child: Align(
            //                             alignment: Alignment.center,
            //                             child: Text(
            //                               "Create Account",
            //                               style: TextStyle(
            //                                 fontFamily: "GothamRnd-Bold",
            //                                 fontSize: 30,
            //                                 fontWeight: FontWeight.bold,
            //                               ),
            //                             ),
            //                           ),
            //                         ),
            //                       ]),
            //                       const SizedBox(height: 25),
            //                       Column(
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         children: [
            //                           const Text(
            //                             "First Name",
            //                             style: TextStyle(
            //                               fontFamily: "GothamRnd",
            //                               color: Color(0xFF393838),
            //                               fontSize: 15,
            //                               fontWeight: FontWeight.bold,
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8),
            //                           TextFormField(
            //                             controller: _firstNameController,
            //                             decoration: InputDecoration(
            //                               filled: true,
            //                               fillColor: Colors.white,
            //                               border: OutlineInputBorder(
            //                                 borderRadius:
            //                                     BorderRadius.circular(10.0),
            //                                 borderSide: BorderSide.none,
            //                               ),
            //                             ),
            //                             validator: (value) {
            //                               if (value == null || value.isEmpty) {
            //                                 return 'Please enter your first name';
            //                               }
            //                               return null; // Return null if there is no error
            //                             },
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           const Text(
            //                             "Last Name",
            //                             style: TextStyle(
            //                               fontFamily: "GothamRnd",
            //                               color: Color(0xFF393838),
            //                               fontSize: 15,
            //                               fontWeight: FontWeight.bold,
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8),
            //                           TextFormField(
            //                             controller: _lastNameController,
            //                             decoration: InputDecoration(
            //                               filled: true,
            //                               fillColor: Colors.white,
            //                               border: OutlineInputBorder(
            //                                 borderRadius:
            //                                     BorderRadius.circular(10.0),
            //                                 borderSide: BorderSide.none,
            //                               ),
            //                             ),
            //                             validator: (value) {
            //                               if (value == null || value.isEmpty) {
            //                                 return 'Please enter your last name';
            //                               }
            //                               return null; // Return null if there is no error
            //                             },
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           const Text(
            //                             "Email Address",
            //                             style: TextStyle(
            //                               fontFamily: "GothamRnd",
            //                               color: Color(0xFF393838),
            //                               fontSize: 15,
            //                               fontWeight: FontWeight.bold,
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           TextFormField(
            //                             controller: _emailController,
            //                             decoration: InputDecoration(
            //                               filled: true,
            //                               fillColor: Colors.white,
            //                               border: OutlineInputBorder(
            //                                 borderRadius:
            //                                     BorderRadius.circular(10.0),
            //                                 borderSide: BorderSide.none,
            //                               ),
            //                             ),
            //                             validator: (value) {
            //                               if (value == null || value.isEmpty) {
            //                                 return 'Please enter a valid email';
            //                               } else if (!RegExp(
            //                                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            //                                   .hasMatch(value)) {
            //                                 return 'Please enter a valid email';
            //                               }
            //                               return null; // Return null if there is no error
            //                             },
            //                             keyboardType: TextInputType.emailAddress,
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           const Text(
            //                             "Password",
            //                             style: TextStyle(
            //                               fontFamily: "GothamRnd-Medium",
            //                               color: Color(0xFF393838),
            //                               fontSize: 15,
            //                               fontWeight: FontWeight.bold,
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           TextFormField(
            //                             controller: _passwordController,
            //                             obscureText: _isObscure,
            //                             decoration: InputDecoration(
            //                               filled: true,
            //                               fillColor: Colors.white,
            //                               border: OutlineInputBorder(
            //                                 borderRadius:
            //                                     BorderRadius.circular(10.0),
            //                                 borderSide: BorderSide.none,
            //                               ),
            //                             ),
            //                             validator: (value) {
            //                               if (value == null || value.isEmpty) {
            //                                 return 'Please enter a password';
            //                               }
            //                               return null; // Return null if there is no error
            //                             },
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           const Text(
            //                             "Confirm Password",
            //                             style: TextStyle(
            //                               fontFamily: "GothamRnd-Medium",
            //                               color: Color(0xFF393838),
            //                               fontSize: 15,
            //                               fontWeight: FontWeight.bold,
            //                             ),
            //                           ),
            //                           const SizedBox(height: 8.0),
            //                           TextFormField(
            //                             controller: _conpasswordController,
            //                             obscureText: _isObscure,
            //                             decoration: InputDecoration(
            //                               filled: true,
            //                               fillColor: Colors.white,
            //                               border: OutlineInputBorder(
            //                                 borderRadius:
            //                                     BorderRadius.circular(10.0),
            //                                 borderSide: BorderSide.none,
            //                               ),
            //                             ),
            //                             validator: (value) {
            //                               if (value == null || value.isEmpty) {
            //                                 return 'Please confirm your password';
            //                               }
            //                               if (value != _passwordController.text) {
            //                                 return 'Passwords do not match';
            //                               }
            //                               return null; // Return null if there is no error
            //                             },
            //                           ),
            //                         ],
            //                       ),
            //                       const SizedBox(height: 20.0),
            //                       ElevatedButton(
            //                         style: ElevatedButton.styleFrom(
            //                           fixedSize: const Size(203, 50),
            //                           backgroundColor: const Color(0xFF274C77),
            //                           shape: RoundedRectangleBorder(
            //                             borderRadius: BorderRadius.circular(
            //                                 10), // Adjust the radius as needed
            //                           ),
            //                         ),
            //                         onPressed: () async {
            //                           if (_formKey.currentState!.validate()) {
            //                             // Perform sign in logic here
            //                             String firstName =
            //                                 _firstNameController.text;
            //                             String lastName =
            //                                 _lastNameController.text;
            //                             String email = _emailController.text;
            //                             String password =
            //                                 _passwordController.text;

            //                             try {
            //                               // ignore: unused_local_variable
            //                               final credential = await FirebaseAuth
            //                                   .instance
            //                                   .createUserWithEmailAndPassword(
            //                                 email: email,
            //                                 password: password,
            //                               );

            //                               String? userID = FirebaseAuth
            //                                   .instance.currentUser?.uid;

            //                               await rtdb
            //                                   .ref("professors/$userID")
            //                                   .set({
            //                                 "firstName": firstName,
            //                                 "lastName": lastName,
            //                                 "profUserID": userID,
            //                                 "mobileNumber": "-",
            //                                 "professorRole": "Employee",
            //                                 "salutation": "",
            //                                 "status": "accepting",
            //                                 "designation": "Professor",
            //                                 "profilePicStatus": "None",
            //                                 "fcmProfToken": "-",
            //                                 "availability": {
            //                                   "Monday": "-",
            //                                   "Tuesday": "-",
            //                                   "Wednesday": "-",
            //                                   "Thursday": "-",
            //                                   "Friday": "-",
            //                                   "Saturday": "-",
            //                                   "Sunday": "-",
            //                                 }
            //                               });

            //                               // ignore: use_build_context_synchronously
            //                               Navigator.pop(context);

            //                               _firstNameController.text = "";
            //                               _lastNameController.text = "";
            //                               _emailController.text = "";
            //                               _passwordController.text = "";
            //                               _conpasswordController.text = "";
            //                             } on FirebaseAuthException catch (e) {
            //                               if (e.code == 'weak-password') {
            //                                 ScaffoldMessenger.of(context)
            //                                     .showSnackBar(
            //                                   const SnackBar(
            //                                       content: Text(
            //                                           'The password provided is too weak.')),
            //                                 );
            //                               } else if (e.code ==
            //                                   'email-already-in-use') {
            //                                 ScaffoldMessenger.of(context)
            //                                     .showSnackBar(
            //                                   const SnackBar(
            //                                       content: Text(
            //                                     'The account already exists for that email.',
            //                                     style: TextStyle(
            //                                         fontFamily: "GothamRnd"),
            //                                   )),
            //                                 );
            //                               }
            //                             } catch (e) {
            //                               ScaffoldMessenger.of(context)
            //                                   .showSnackBar(
            //                                 const SnackBar(
            //                                     content: Text(
            //                                   'Error.',
            //                                   style: TextStyle(
            //                                       fontFamily: "GothamRnd"),
            //                                 )),
            //                               );
            //                             }
            //                           }
            //                         },
            //                         child: const Text(
            //                           'Create Account',
            //                           style: TextStyle(
            //                             fontFamily: "GothamRnd",
            //                             color: Colors.white,
            //                             fontSize: 15,
            //                           ),
            //                         ),
            //                       ),
            //                       const SizedBox(height: 30),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ],
            //             // ),
            //             // ),
            //           )

            //           // },
            //           ),
            //     ),
            //   );
          },
          label: const Text(
            'Create Account',
            style: TextStyle(fontFamily: "GothamRnd"),
          ),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF274C77),
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
  // ignore: library_private_types_in_public_api
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
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 50,
            left: MediaQuery.of(context).size.width / 20,
            right: MediaQuery.of(context).size.width / 20),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search',
            hintStyle: TextStyle(fontFamily: "GothamRnd", color: Colors.grey),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF274C77),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(
                color: Color(0xFF274C77),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(
                color: Color(0xFF274C77),
              ),
            ),
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}

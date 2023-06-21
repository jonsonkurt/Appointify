import 'package:appointify/view/student/bottom_navigation_bar.dart';
import 'package:appointify/view/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conpasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _conpasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _conpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          mediaQuery.size.height * 0.1,
        ),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.fromLTRB(
              mediaQuery.size.width * 0.035,
              mediaQuery.size.height * 0.028,
              0,
              0,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width / 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontFamily: "GothamRnd",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Surname",
                                  style: TextStyle(
                                    fontFamily: "GothamRnd",
                                    color: Color(0xFF393838),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 8),
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
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
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
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Password",
                                  style: TextStyle(
                                    fontFamily: "GothamRnd",
                                    color: Color(0xFF393838),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                      child: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF274C77),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    return null; // Return null if there is no error
                                  },
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Confirm Password",
                                  style: TextStyle(
                                    fontFamily: "GothamRnd",
                                    color: Color(0xFF393838),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _conpasswordController,
                                  obscureText: !_passwordVisible,
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _conpasswordVisible =
                                              !_conpasswordVisible;
                                        });
                                      },
                                      child: Icon(
                                        _conpasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF274C77),
                                      ),
                                    ),
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
                                const SizedBox(height: 30.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Perform sign in logic here
                            String firstName = _firstNameController.text;
                            String lastName = _lastNameController.text;
                            String email = _emailController.text;
                            String password = _passwordController.text;

                            try {
                              // ignore: unused_local_variable
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                              String? userID =
                                  FirebaseAuth.instance.currentUser?.uid;
                              final fcmToken =
                                  await FirebaseMessaging.instance.getToken();
                              await FirebaseDatabase.instance
                                  .ref("students/$userID")
                                  .set({
                                "firstName": firstName,
                                "lastName": lastName,
                                "designation": "Student",
                                "email": email,
                                "mobileNumber": "-",
                                "section": "-",
                                "profilePicStatus": "None",
                                "UID": userID,
                                "fcmToken": fcmToken,
                                "notifState": "no"
                                // "address": {"line1": "100 Mountain View"}
                              });
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BottomNavigation()),
                              );
                              _firstNameController.clear();
                              _lastNameController.clear();
                              _emailController.clear();
                              _passwordController.clear();
                              _conpasswordController.clear();
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'The password provided is too weak.')),
                                );
                              } else if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'The account already exists for that email.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                  'Error.',
                                  style: TextStyle(
                                    fontFamily: "GothamRnd",
                                  ),
                                )),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(203, 50),
                          backgroundColor: const Color(0xFF274C77),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: "GothamRnd",
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          _emailController.clear();
                          _passwordController.clear();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SignInPage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var begin = const Offset(0.0, 1.0);
                                var end = Offset.zero;
                                var curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          ); // Handle sign up
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "I'm already a member. ",
                            style: TextStyle(
                              fontFamily: "GothamRnd",
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF393838),
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  fontFamily: "GothamRnd",
                                  color: Color(0xFF274C77),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

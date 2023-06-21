import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';

import 'admin_cred.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);
  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Redirect the user to the SignInPage after logging out
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  _showPasswordModal() {
    showModalBottomSheet<dynamic>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
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
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          }
                          return null; // Return null if there is no error
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordConfirmController,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _passwordController.text) {
                            return 'Password is not match';
                          }
                          return null; // Return null if there is no error
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(155, 32),
                          backgroundColor: const Color(0xFF7778EE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String password = _passwordController.text;

                            encryptPassword(password);

                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);

                            _passwordController.text = "";
                            _passwordConfirmController.text = "";

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password Updated'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Update Password',
                        ),
                      ),
                      const SizedBox(height: 40),
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF274C77),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 8),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFA2C2FF),
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the border radius as needed
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors
                          .white, // Replace 'Colors.blue' with the desired color
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Text(
                  "Admin",
                  style: TextStyle(
                    fontFamily: "GothamRnd",
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const SizedBox(
              height: 55,
            ),
            ElevatedButton(
              onPressed: _showPasswordModal,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 40),
                backgroundColor: const Color(0xFF6096BA),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Adjust the radius as needed
                ),
              ),
              child: const Text(
                "Update Password",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "GothamRnd",
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(130, 10),
                backgroundColor: const Color(0xFFA3CEF1),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(5), // Adjust the radius as needed
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "GothamRnd",
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

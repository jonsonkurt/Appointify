import 'package:appointify/view/forgot_password_page.dart';
import 'package:appointify/view/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loading_page.dart';
import 'sign_up_page.dart';
import 'admin/admin_page.dart';
import 'admin/admin_cred.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomePage()),
                        );
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 110,
                    bottom: MediaQuery.of(context).size.height / 110),
                child: Center(
                  child: Image.asset(
                    'assets/images/sign_in.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontFamily: "GothamRnd-Bold",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email Address",
                            style: TextStyle(
                              fontFamily: "GothamRnd-Medium",
                              color: Color(0xFF393838),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () =>
                                  FocusScope.of(context).nextFocus(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontFamily: "GothamRnd-Medium",
                              color: Color(0xFF393838),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextFormField(
                              obscureText: !_passwordVisible,
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
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
                                    color: const Color(0xFFFF9343),
                                  ),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // _emailController.clear();
                            // _passwordController
                            //     .clear(); // Handle forgot password
                            // ignore: use_build_context_synchronously

                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ForgotPasswordPage(),
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
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontFamily: "GothamRnd-Medium",
                              color: Color(0xFF393838),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            String email = _emailController.text;
                            String password = _passwordController.text;

                            String getCred = decodingCred();
                            bool isPasswordCorrect =
                                await checkPassword(password);
                            if (email == getCred) {
                              // print("I/'m an admin");
                              if (isPasswordCorrect) {
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BottomNavigationAdmin()));
                              } else {
                                logger.d('Password is incorrect');
                              }
                            } else {
                              // if (email == getCred) {
                              //   // print("I/'m an admin");
                              //   if (isPasswordCorrect) {
                              //     // ignore: use_build_context_synchronously
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) =>
                              //                 const BottomNavigationAdmin()));
                              //   } else {
                              //     logger.d('Password is incorrect');
                              //   }
                              // } else {
                              try {
                                // ignore: unused_local_variable
                                final credential = await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: email, password: password);

                                // ignore: use_build_context_synchronously
                                Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoadingPage()));
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  //  print('No user found for that email.');
                                } else if (e.code == 'wrong-password') {
                                  // print('Wrong password provided for that user.');
                                }
                              }
                            }
                            _emailController.clear();
                            _passwordController.clear();
                          }, // Handle sign in

                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(203, 50),
                            backgroundColor: const Color(0xFFFF9343),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Adjust the radius as needed
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: "GothamRnd-Medium.otf",
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () {
                          _emailController.clear();
                          _passwordController.clear();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SignUpPage(),
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
                            text: "I'm a new user. ",
                            style: TextStyle(
                              fontFamily: "GothamRnd-Medium",
                              color: Color(0xFF393838),
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  fontFamily: "GothamRnd-Medium",
                                  color: Color(0xFFFF9343),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 55),
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

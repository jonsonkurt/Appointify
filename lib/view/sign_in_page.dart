import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:appointify/view/screen.dart';
// import 'admin_page.dart';
import 'student/bottom_navigation_bar.dart';
import 'sign_up_page.dart';
import 'admin/admin_page.dart';
import 'admin/admin_cred.dart';
// import 'forgot_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

   @override
  void initState() {
    super.initState();
    _emailController.addListener(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                // Handle sign up navigation here
              },
              child: const Text(
                "Forgot Password",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Perform sign in logic here
                String email = _emailController.text;
                String password = _passwordController.text;

                String getCred = decodingCred();

                if (email == getCred && password == getCred) {
                  // ignore: use_build_context_synchronously
                  // print("I/'m an admin");
                  Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BottomNavigationAdmin()));
                } else {
                  try {
                    // ignore: unused_local_variable
                    final credential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);

                    // ignore: use_build_context_synchronously
                    Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BottomNavigation()));
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      // print('No user found for that email.');
                    } else if (e.code == 'wrong-password') {
                      // print('Wrong password provided for that user.');
                    }
                  }
                }
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SignUpPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
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
                );
              },
              child: const Text(
                "I'm a new user. Sign Up",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

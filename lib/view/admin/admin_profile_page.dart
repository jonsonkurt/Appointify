import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);
  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            alignment: Alignment.topCenter,
            child: Icon(Icons.account_box_rounded, size: 100,),
          
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: const Text("Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
          ElevatedButton(
            onPressed: _logout,
            child: const Text("Logout", style: TextStyle(fontSize: 20),),
          ),
        ]),
      ),
    );
  }
}

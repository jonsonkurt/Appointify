import 'package:appointify/view/professor/professor_request_page.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'professor_home_page.dart';
import 'professor_profile_page.dart';

class ProfessorBottomNavigation extends StatefulWidget {
  const ProfessorBottomNavigation({super.key});

  @override
  State<ProfessorBottomNavigation> createState() =>
      _ProfessorBottomNavigationState();
}

class _ProfessorBottomNavigationState extends State<ProfessorBottomNavigation> {
  var currentIndex = 0;
  var pages = const [
    HomePage(),
    RequestPage(),
    ProfessorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: SafeArea(
          child: SalomonBottomBar(
            margin: const EdgeInsets.only(left: 50, right: 60),
            itemPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            currentIndex: currentIndex,
            backgroundColor: const Color(0xFFFF9343),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Home"),
                selectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.inbox),
                title: const Text("Requests"),
                selectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: const Text("Profile"),
                selectedColor: Colors.white,
              ),
            ],
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
        body: pages[currentIndex],
      ),
    );
  }
}

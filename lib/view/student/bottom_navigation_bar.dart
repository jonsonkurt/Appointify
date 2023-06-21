import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'home_page.dart';
import 'org_chart_page.dart';
import 'professor_page.dart';
import 'profile_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  var currentIndex = 0;
  var pages = const [
    HomePage(),
    ProfessorPage(),
    OrgChartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: SafeArea(
          child: SalomonBottomBar(
            selectedColorOpacity: 0,
            backgroundColor: const Color(0xFF274C77),
            currentIndex: currentIndex,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Home"),
                selectedColor: Colors.white,
                unselectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.list_alt),
                title: const Text("Employee"),
                selectedColor: Colors.white,
                unselectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.groups),
                title: const Text("Org Chart"),
                selectedColor: Colors.white,
                unselectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: const Text("Profile"),
                selectedColor: Colors.white,
                unselectedColor: Colors.white,
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

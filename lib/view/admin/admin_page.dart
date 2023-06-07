import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../home_page.dart';
import '../org_chart_page.dart';
import '../professor_page.dart';
import '../profile_page.dart';

class BottomNavigationAdmin extends StatefulWidget {
  const BottomNavigationAdmin({super.key});

  @override
  State<BottomNavigationAdmin> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationAdmin> {
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
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: currentIndex,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
              selectedColor: Colors.pink,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.list),
              title: const Text("Professor"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.people),
              title: const Text("Org Chart"),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text("Profile"),
              selectedColor: Colors.teal,
            ),
          ],
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
        body: pages[currentIndex],
      ),
    );
  }
}

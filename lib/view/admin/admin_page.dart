import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'admin_home_page.dart';
import 'admin_org_chart_page.dart';
import 'admin_profile_page.dart';

class BottomNavigationAdmin extends StatefulWidget {
  const BottomNavigationAdmin({super.key});

  @override
  State<BottomNavigationAdmin> createState() => _BottomNavigationStateAdmin();
}

class _BottomNavigationStateAdmin extends State<BottomNavigationAdmin> {
  var currentIndex = 0;
  var pages = const [
    HomePageAdmin(),
    OrgChartPage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff274C77),
        bottomNavigationBar: SafeArea(
          child: SalomonBottomBar(
            selectedColorOpacity: 0,
            margin: const EdgeInsets.only(left: 30, right: 30),
            itemPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            currentIndex: currentIndex,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text(
                  "Home",
                  style: TextStyle(fontFamily: "GothamRnd"),
                ),
                selectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.list_alt),
                title: const Text(
                  "Organization chart",
                  style: TextStyle(fontFamily: "GothamRnd"),
                ),
                selectedColor: Colors.white,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.people),
                title: const Text(
                  "Profile",
                  style: TextStyle(fontFamily: "GothamRnd"),
                ),
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

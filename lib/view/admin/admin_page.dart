import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'admin_home_page.dart';
import 'admin_org_chart_page.dart';


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
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xffFF9343),
        bottomNavigationBar: SalomonBottomBar(
         margin: const EdgeInsets.only(left: 50, right: 60),
          itemPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          currentIndex: currentIndex,

          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
              selectedColor: Colors.white,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.people),
              title: const Text("Organization chart"),
              selectedColor: Colors.white,
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
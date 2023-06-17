import 'package:flutter/material.dart';

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({super.key});

  @override
  State<OrgChartPage> createState() => _OrgChartPageState();
}

class _OrgChartPageState extends State<OrgChartPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Text("Org Chart Page"),
          ),
        ),
      ),
    );
  }
}

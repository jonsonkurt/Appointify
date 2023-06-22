import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AddOrgChartPage extends StatefulWidget {
  const AddOrgChartPage({Key? key}) : super(key: key);

  @override
  _AddOrgChartPageState createState() => _AddOrgChartPageState();
}

class _AddOrgChartPageState extends State<AddOrgChartPage> {
  var logger = Logger();
  var nameTECs = <TextEditingController>[];
  var position1 = <TextEditingController>[];
  var facultyTECs = <TextEditingController>[]; // List for faculty controllers
  var position2 = <TextEditingController>[]; // List for position controllers
  var position3 = <TextEditingController>[];
  int? index;

  StreamSubscription<DatabaseEvent>? orgChartSubscription;

  var nameController = TextEditingController();
  var position1Controller = TextEditingController();
  var facultyController = TextEditingController(); // Controller for faculty
  var position2Controller = TextEditingController();
  var position3Controller = TextEditingController();

  DatabaseReference orgChartRef =
      FirebaseDatabase.instance.ref('organizationChart');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    orgChartSubscription?.cancel();
    super.dispose();
  }

  String getPositionRank(String position) {
    switch (position) {
      case 'University President':
        return "1";
      case 'Vice President for Academic Affairs':
        return "2";
      case 'Dean':
        return "3";
      case 'Department Chairperson':
        return "4";
      case 'BSCE Program Coordinator':
      case 'Department Secretary':
      case 'Job Placement Officer':
      case 'OJT Coordinator':
      case 'Department Extension Coordinator':
      case 'Budget Officer/ Property Custodian':
      case 'Department BSCE Research Coordinator':
      case 'GAD Coordinator':
      case 'In-Charge Knowledge Management Unit':
      case 'Program Coordinator, BS Archi':
      case 'Research Coordinator, BS Archi':
      case 'CE Faculty':
      case 'DRAW/CADD Faculty':
        return "5";
      case 'Archi Faculty':
        return "6";
      default:
        return "Not Found";
    }
  }

  _onDone() {
    var name = nameController.text;
    var pos1 = selectedPosition1 ?? '';
    var faculty = selectedFaculty ?? '';
    var pos2 = selectedPosition2 ?? '';
    var pos3 = selectedPosition3 ?? '';

    String highestRank = "6";
    List<String> positions = [pos1, pos2, pos3, faculty];
    for (String position in positions) {
      String rank = getPositionRank(position);

      if (rank.compareTo(highestRank) < 0) {
        highestRank = rank;
      }
    }

    FirebaseDatabase.instance.ref('organizationChart/$index').set({
      'id': index,
      'name': name,
      'position1': pos1,
      'faculty': faculty,
      'position2': pos2,
      'position3': pos3,
      'rank': highestRank,
    });

    setState(() {
      nameController.clear();
      selectedPosition1 = null;
      selectedFaculty = null;
      selectedPosition2 = null;
      selectedPosition3 = null;
    });
  }

  String? selectedPosition1;
  String? selectedPosition2;
  String? selectedPosition3;
  String? selectedFaculty;

  @override
  Widget build(BuildContext context) {
    orgChartSubscription = orgChartRef.onValue.listen((event) {
      try {
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic> data =
            Map<dynamic, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        index = data.length;
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Organizational Chart"),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
        ),
        body: Column(
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPosition1,
                    decoration: const InputDecoration(labelText: 'Position 1'),
                    onChanged: (value) {
                      setState(() {
                        selectedPosition1 = value;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: '-',
                        child: Text('-'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'University President',
                        child: Text('University President'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Vice President for Academic Affairs',
                        child: Text('Vice President for Academic Affairs'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Dean',
                        child: Text('Dean'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Chairperson',
                        child: Text('Department Chairperson'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'BSCE Program Coordinator',
                        child: Text('BSCE Program Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Secretary',
                        child: Text('Department Secretary'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Job Placement Officer',
                        child: Text('Job Placement Officer'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'OJT Coordinator',
                        child: Text('OJT Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Extension Coordinator',
                        child: Text('Department Extension Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Budget Officer/Property Custodian',
                        child: Text('Budget Officer/Property Custodian'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department BSCE Research Coordinator',
                        child: Text('Department BSCE Research Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'GAD Coordinator',
                        child: Text('GAD Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'In-Charge Knowledge Management Unit',
                        child: Text('In-Charge Knowledge Management Unit'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Program Coordinator, BS Archi',
                        child: Text('Program Coordinator, BS Archi'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Research Coordinator, BS Archi',
                        child: Text('Research Coordinator, BS Archi'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'CE Faculty',
                        child: Text('CE Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'DRAW/CADD Faculty',
                        child: Text('DRAW/CADD Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Archi Faculty',
                        child: Text('Archi Faculty'),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPosition2,
                    decoration: const InputDecoration(labelText: 'Position 2'),
                    onChanged: (value) {
                      setState(() {
                        selectedPosition2 = value;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: '-',
                        child: Text('-'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'University President',
                        child: Text('University President'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Vice President for Academic Affairs',
                        child: Text('Vice President for Academic Affairs'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Dean',
                        child: Text('Dean'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Chairperson',
                        child: Text('Department Chairperson'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'BSCE Program Coordinator',
                        child: Text('BSCE Program Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Secretary',
                        child: Text('Department Secretary'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Job Placement Officer',
                        child: Text('Job Placement Officer'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'OJT Coordinator',
                        child: Text('OJT Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Extension Coordinator',
                        child: Text('Department Extension Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Budget Officer/Property Custodian',
                        child: Text('Budget Officer/Property Custodian'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department BSCE Research Coordinator',
                        child: Text('Department BSCE Research Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'GAD Coordinator',
                        child: Text('GAD Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'In-Charge Knowledge Management Unit',
                        child: Text('In-Charge Knowledge Management Unit'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Program Coordinator, BS Archi',
                        child: Text('Program Coordinator, BS Archi'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Research Coordinator, BS Archi',
                        child: Text('Research Coordinator, BS Archi'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'CE Faculty',
                        child: Text('CE Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'DRAW/CADD Faculty',
                        child: Text('DRAW/CADD Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Archi Faculty',
                        child: Text('Archi Faculty'),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPosition3,
                    decoration: const InputDecoration(labelText: 'Position 3'),
                    onChanged: (value) {
                      setState(() {
                        selectedPosition3 = value;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: '-',
                        child: Text('-'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'University President',
                        child: Text('University President'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Vice President for Academic Affairs',
                        child: Text('Vice President for Academic Affairs'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Dean',
                        child: Text('Dean'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Chairperson',
                        child: Text('Department Chairperson'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'BSCE Program Coordinator',
                        child: Text('BSCE Program Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Secretary',
                        child: Text('Department Secretary'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Job Placement Officer',
                        child: Text('Job Placement Officer'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'OJT Coordinator',
                        child: Text('OJT Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department Extension Coordinator',
                        child: Text('Department Extension Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Budget Officer/Property Custodian',
                        child: Text('Budget Officer/Property Custodian'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Department BSCE Research Coordinator',
                        child: Text('Department BSCE Research Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'GAD Coordinator',
                        child: Text('GAD Coordinator'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'In-Charge Knowledge Management Unit',
                        child: Text('In-Charge Knowledge Management Unit'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Program Coordinator, BS Archi',
                        child: Text('Program Coordinator, BS Archi'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Research Coordinator, BS Archi',
                        child: Text('Research Coordinator, BS Archi'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'CE Faculty',
                        child: Text('CE Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'DRAW/CADD Faculty',
                        child: Text('DRAW/CADD Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Archi Faculty',
                        child: Text('Archi Faculty'),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedFaculty,
                    decoration: const InputDecoration(labelText: 'Faculty'),
                    onChanged: (value) {
                      setState(() {
                        selectedFaculty = value;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: '-',
                        child: Text('-'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'CE Faculty',
                        child: Text('CE Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Archi Faculty',
                        child: Text('Archi Faculty'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'DRAW/CADD Faculty',
                        child: Text('DRAW/CADD Faculty'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onDone,
          child: const Icon(Icons.done),
        ),
      ),
    );
  }
}

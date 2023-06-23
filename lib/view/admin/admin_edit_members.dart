import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class EditOrgChartPage extends StatefulWidget {
  final String empName;
  final String empPos1;
  final String empPos2;
  final String empPos3;
  final String empFaculty;
  final String empID;
  const EditOrgChartPage(
      {Key? key,
      required this.empName,
      required this.empPos1,
      required this.empPos2,
      required this.empPos3,
      required this.empFaculty,
      required this.empID})
      : super(key: key);

  @override
  _EditOrgChartPageState createState() => _EditOrgChartPageState();
}

class _EditOrgChartPageState extends State<EditOrgChartPage> {
  var logger = Logger();

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
    nameController.text = widget.empName;
    position1Controller.text = widget.empPos1;
    position2Controller.text = widget.empPos2;
    position3Controller.text = widget.empPos3;
    facultyController.text = widget.empFaculty;
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

    print("NAME - - - -$name");
    String highestRank = "6";
    List<String> positions = [pos1, pos2, pos3, faculty];
    for (String position in positions) {
      String rank = getPositionRank(position);

      if (rank.compareTo(highestRank) < 0) {
        highestRank = rank;
      }
    }

    FirebaseDatabase.instance.ref('organizationChart/${widget.empID}').update({
      'id': widget.empID,
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

    Navigator.pop(context);
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
          elevation: 0,
          backgroundColor: const Color(0xFF274C77),
          title: const Text("Edit Employee"),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF274C77),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0),
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Edit Employee",
                          style: TextStyle(
                              fontFamily: "GothamRnd",
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 15.0),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Full Name",
                              style: TextStyle(
                                fontFamily: "GothamRnd",
                                color: Color(0xFF393838),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(
                                color: Colors.black, fontFamily: "GothamRnd"),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20.0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Position 1',
                              style: TextStyle(
                                fontFamily: "GothamRnd",
                                color: Color(0xFF393838),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          child: DropdownButtonFormField<String>(
                            value: selectedPosition1,
                            style: const TextStyle(
                                color: Colors.black, fontFamily: "GothamRnd"),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20.0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
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
                                child:
                                    Text('Vice President for Academic Affairs'),
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
                                child:
                                    Text('Budget Officer/Property Custodian'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Department BSCE Research Coordinator',
                                child: Text(
                                    'Department BSCE Research Coordinator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'GAD Coordinator',
                                child: Text('GAD Coordinator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'In-Charge Knowledge Management Unit',
                                child:
                                    Text('In-Charge Knowledge Management Unit'),
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
                        ),
                        const SizedBox(height: 15.0),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Position 2",
                              style: TextStyle(
                                fontFamily: "GothamRnd",
                                color: Color(0xFF393838),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          child: DropdownButtonFormField<String>(
                            value: selectedPosition2,
                            style: const TextStyle(
                                color: Colors.black, fontFamily: "GothamRnd"),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20.0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
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
                                child:
                                    Text('Vice President for Academic Affairs'),
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
                                child:
                                    Text('Budget Officer/Property Custodian'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Department BSCE Research Coordinator',
                                child: Text(
                                    'Department BSCE Research Coordinator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'GAD Coordinator',
                                child: Text('GAD Coordinator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'In-Charge Knowledge Management Unit',
                                child:
                                    Text('In-Charge Knowledge Management Unit'),
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
                        ),
                        const SizedBox(height: 15.0),
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Position 3",
                              style: TextStyle(
                                fontFamily: "GothamRnd",
                                color: Color(0xFF393838),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          child: DropdownButtonFormField<String>(
                            value: selectedPosition3,
                            style: const TextStyle(
                                color: Colors.black, fontFamily: "GothamRnd"),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20.0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
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
                                child:
                                    Text('Vice President for Academic Affairs'),
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
                                child:
                                    Text('Budget Officer/Property Custodian'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Department BSCE Research Coordinator',
                                child: Text(
                                    'Department BSCE Research Coordinator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'GAD Coordinator',
                                child: Text('GAD Coordinator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'In-Charge Knowledge Management Unit',
                                child:
                                    Text('In-Charge Knowledge Management Unit'),
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
                        ),
                        const SizedBox(height: 15.0),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Faculty",
                            style: TextStyle(
                              fontFamily: "GothamRnd",
                              color: Color(0xFF393838),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(30),
                          child: DropdownButtonFormField<String>(
                            value: selectedFaculty,
                            style: const TextStyle(
                                color: Colors.black, fontFamily: "GothamRnd"),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(20.0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
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
                        ),
                        const SizedBox(height: 50.0),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF274C77),
          onPressed: _onDone,
          child: const Icon(Icons.done),
        ),
      ),
    );
  }
}

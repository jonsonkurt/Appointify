import 'dart:async';
import 'dart:io';

import 'package:appointify/view/admin/admin_image_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddOrgChartPage extends StatefulWidget {
  List<String> neededPosition;
  AddOrgChartPage({Key? key, required this.neededPosition}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddOrgChartPageState createState() => _AddOrgChartPageState();
}

class _AddOrgChartPageState extends State<AddOrgChartPage> {
  var logger = Logger();
  String valPos1 = '-';
  String valPos2 = '-';
  String valPos3 = '-';
  int? index;

  StreamSubscription<DatabaseEvent>? orgChartSubscription;

  var nameController = TextEditingController();
  var position1Controller = TextEditingController();
  var facultyController = TextEditingController(); // Controller for faculty
  var position2Controller = TextEditingController();
  var position3Controller = TextEditingController();
  String getLink = "";

  DatabaseReference orgChartRef =
      FirebaseDatabase.instance.ref('organizationChart');

  @override
  void initState() {
    // checkPositions();

    selectedPosition1 = "-";
    selectedFaculty = "-";
    selectedPosition2 = "-";
    selectedPosition3 = "-";
    super.initState();
  }

  @override
  void dispose() {
    orgChartSubscription?.cancel();
    super.dispose();
  }

  // Future<List<String>> checkPositions() async {
  //   DatabaseReference databaseReference =
  //       FirebaseDatabase.instance.ref().child('organizationChart');

  //   DatabaseEvent event = await databaseReference.once();

  //   List<String> positions = [
  //     'University President',
  //     'Vice President for Academic Affairs',
  //     'Dean',
  //     'Department Chairperson',
  //     'BSCE Program Coordinator',
  //     'Department Secretary',
  //     'Job Placement Officer',
  //     'OJT Coordinator',
  //     'Department Extension Coordinator',
  //     'Budget Officer/Property Custodian',
  //     'Department BSCE Research Coordinator',
  //     'GAD Coordinator',
  //     'In-Charge Knowledge Management Unit',
  //     'Program Coordinator, BS Archi',
  //     'Research Coordinator, BS Archi'
  //   ];

  //   Set<String> takenPositions = <String>{};

  //   if (event.snapshot.value != null) {
  //     Map<dynamic, dynamic>? values =
  //         event.snapshot.value as Map<dynamic, dynamic>?;
  //     values?.forEach((key, value) {
  //       Map<String, dynamic> childData = Map<String, dynamic>.from(value);
  //       if (childData['position1'] != null) {
  //         takenPositions.add(childData['position1']);
  //       }
  //       if (childData['position2'] != null) {
  //         takenPositions.add(childData['position2']);
  //       }
  //       if (childData['position3'] != null) {
  //         takenPositions.add(childData['position3']);
  //       }
  //     });
  //   }

  //   List<String> availablePositions = positions
  //       .where((position) => !takenPositions.contains(position))
  //       .toList();

  //   if (availablePositions.isEmpty) {
  //     return [];
  //   } else {
  //     widget.neededPosition = availablePositions;
  //     return availablePositions;
  //   }
  // }

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
      case 'Budget Officer/Property Custodian':
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

  _onDone() async {
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

    await FirebaseDatabase.instance.ref('organizationChart/$index').set({
      'id': index,
      'name': name,
      'position1': pos1,
      'faculty': faculty,
      'position2': pos2,
      'position3': pos3,
      'rank': highestRank,
      'imageURL': getLink,
    });
    // if (getLink != "") {
    //   await FirebaseDatabase.instance.ref('organizationChart/$index').update({
    //     'imageURL': getLink,
    //   });
    // }

    setState(() {
      nameController.clear();
      selectedPosition1 = "-";
      selectedFaculty = "-";
      selectedPosition2 = "-";
      selectedPosition3 = "-";
    });
  }

  String? selectedPosition1;
  String? selectedPosition2;
  String? selectedPosition3;
  String? selectedFaculty;

  @override
  Widget build(BuildContext context) {
    // print("NEEDED POSITION $widget.neededPosition");
    orgChartSubscription = orgChartRef.onValue.listen((event) {
      try {
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List getIDs = [];
        index = data.length + 1;
        data.forEach((key, value) {
          if (value["id"] != null) {
            getIDs.add(value["id"]);
          }
        });
        int getLastIndex = getIDs
            .reduce((value, element) => value > element ? value : element);
        index = getLastIndex + 1;
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    return ChangeNotifierProvider(
      create: (_) => AdminProfileController(),
      child:
          Consumer<AdminProfileController>(builder: (context, provider, child) {
        return WillPopScope(
          onWillPop: () async {
            return false; // Disable back button
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFF274C77),
              title: const Text(
                "Add Employee",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontFamily: "GothamRnd",
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.arrow_back_rounded)),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(
                              0xFF274C77), // Set the background color of the box
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          // Set the border radius of the box
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: GestureDetector(
                          onTap: () {
                            provider.pickImage(context);
                          },
                          child: Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color(0xFF274C77),
                                  width: 2,
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: provider.image == null
                                  ? const Icon(
                                      Icons.add_circle,
                                      size: 35,
                                      color: Color(0xFF274C77),
                                    )
                                  : Image.file(
                                      fit: BoxFit.cover,
                                      File(provider.image!.path).absolute),
                            ),
                          ),
                        ),
                      ),
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
                                    color: Colors.black,
                                    fontFamily: "GothamRnd"),
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
                                    color: Colors.black,
                                    fontFamily: "GothamRnd"),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(20.0),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                onChanged: (value) async {
                                  setState(() {
                                    selectedPosition1 = value;
                                    if (selectedPosition2 == value) {
                                      selectedPosition2 = '-';
                                    }

                                    if (selectedPosition3 == value) {
                                      selectedPosition3 = '-';
                                    }
                                  });
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: '-',
                                    child: Text('-'),
                                  ),
                                  //
                                  if (selectedPosition2 !=
                                          'University President' ||
                                      selectedPosition3 !=
                                          'University President')
                                    if (widget.neededPosition
                                            .contains("University President") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'University President',
                                        child: Text('University President'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Vice President for Academic Affairs' ||
                                      selectedPosition3 !=
                                          'Vice President for Academic Affairs')
                                    if (widget.neededPosition.contains(
                                            "Vice President for Academic Affairs") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Vice President for Academic Affairs',
                                        child: Text(
                                            'Vice President for Academic Affairs'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'Dean' ||
                                      selectedPosition3 != 'Dean')
                                    if (widget.neededPosition
                                            .contains("Dean") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Dean',
                                        child: Text('Dean'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Chairperson' ||
                                      selectedPosition3 !=
                                          'Department Chairperson')
                                    if (widget.neededPosition.contains(
                                            "Department Chairperson") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Department Chairperson',
                                        child: Text('Department Chairperson'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'BSCE Program Coordinator' ||
                                      selectedPosition3 !=
                                          'BSCE Program Coordinator')
                                    if (widget.neededPosition.contains(
                                            "BSCE Program Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'BSCE Program Coordinator',
                                        child: Text('BSCE Program Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Secretary' ||
                                      selectedPosition3 !=
                                          'Department Secretary')
                                    if (widget.neededPosition
                                            .contains("Department Secretary") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Department Secretary',
                                        child: Text('Department Secretary'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Job Placement Officer' ||
                                      selectedPosition3 !=
                                          'Job Placement Officer')
                                    if (widget.neededPosition.contains(
                                            "Job Placement Officer") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Job Placement Officer',
                                        child: Text('Job Placement Officer'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'OJT Coordinator' ||
                                      selectedPosition3 != 'OJT Coordinator')
                                    if (widget.neededPosition
                                            .contains("OJT Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'OJT Coordinator',
                                        child: Text('OJT Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Extension Coordinator' ||
                                      selectedPosition3 !=
                                          'Department Extension Coordinator')
                                    if (widget.neededPosition.contains(
                                            "Department Extension Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Department Extension Coordinator',
                                        child: Text(
                                            'Department Extension Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Budget Officer/Property Custodian' ||
                                      selectedPosition3 !=
                                          'Budget Officer/Property Custodian')
                                    if (widget.neededPosition.contains(
                                            "Budget Officer/Property Custodian") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Budget Officer/Property Custodian',
                                        child: Text(
                                            'Budget Officer/Property Custodian'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department BSCE Research Coordinator' ||
                                      selectedPosition3 !=
                                          'Department BSCE Research Coordinator')
                                    if (widget.neededPosition.contains(
                                            "Department BSCE Research Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Department BSCE Research Coordinator',
                                        child: Text(
                                            'Department BSCE Research Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'GAD Coordinator' ||
                                      selectedPosition3 != 'GAD Coordinator')
                                    if (widget.neededPosition
                                            .contains("GAD Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'GAD Coordinator',
                                        child: Text('GAD Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'In-Charge Knowledge Management Unit' ||
                                      selectedPosition3 !=
                                          'In-Charge Knowledge Management Unit')
                                    if (widget.neededPosition.contains(
                                            "In-Charge Knowledge Management Unit") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'In-Charge Knowledge Management Unit',
                                        child: Text(
                                            'In-Charge Knowledge Management Unit'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Program Coordinator, BS Archi' ||
                                      selectedPosition3 !=
                                          'Program Coordinator, BS Archi')
                                    if (widget.neededPosition.contains(
                                            "Program Coordinator, BS Archi") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Program Coordinator, BS Archi',
                                        child: Text(
                                            'Program Coordinator, BS Archi'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Research Coordinator, BS Archi' ||
                                      selectedPosition3 !=
                                          'Research Coordinator, BS Archi')
                                    if (widget.neededPosition.contains(
                                            "Research Coordinator, BS Archi") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Research Coordinator, BS Archi',
                                        child: Text(
                                            'Research Coordinator, BS Archi'),
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
                                    color: Colors.black,
                                    fontFamily: "GothamRnd"),
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
                                    if (selectedPosition1 == value) {
                                      selectedPosition1 = '-';
                                    }

                                    if (selectedPosition3 == value) {
                                      selectedPosition3 = '-';
                                    }
                                  });
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: '-',
                                    child: Text('-'),
                                  ),
                                  //
                                  if (selectedPosition2 !=
                                          'University President' ||
                                      selectedPosition3 !=
                                          'University President')
                                    if (widget.neededPosition
                                            .contains("University President") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'University President',
                                        child: Text('University President'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Vice President for Academic Affairs' ||
                                      selectedPosition3 !=
                                          'Vice President for Academic Affairs')
                                    if (widget.neededPosition.contains(
                                            "Vice President for Academic Affairs") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Vice President for Academic Affairs',
                                        child: Text(
                                            'Vice President for Academic Affairs'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'Dean' ||
                                      selectedPosition3 != 'Dean')
                                    if (widget.neededPosition
                                            .contains("Dean") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Dean',
                                        child: Text('Dean'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Chairperson' ||
                                      selectedPosition3 !=
                                          'Department Chairperson')
                                    if (widget.neededPosition.contains(
                                            "Department Chairperson") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Department Chairperson',
                                        child: Text('Department Chairperson'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'BSCE Program Coordinator' ||
                                      selectedPosition3 !=
                                          'BSCE Program Coordinator')
                                    if (widget.neededPosition.contains(
                                            "BSCE Program Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'BSCE Program Coordinator',
                                        child: Text('BSCE Program Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Secretary' ||
                                      selectedPosition3 !=
                                          'Department Secretary')
                                    if (widget.neededPosition
                                            .contains("Department Secretary") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Department Secretary',
                                        child: Text('Department Secretary'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Job Placement Officer' ||
                                      selectedPosition3 !=
                                          'Job Placement Officer')
                                    if (widget.neededPosition.contains(
                                            "Job Placement Officer") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Job Placement Officer',
                                        child: Text('Job Placement Officer'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'OJT Coordinator' ||
                                      selectedPosition3 != 'OJT Coordinator')
                                    if (widget.neededPosition
                                            .contains("OJT Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'OJT Coordinator',
                                        child: Text('OJT Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Extension Coordinator' ||
                                      selectedPosition3 !=
                                          'Department Extension Coordinator')
                                    if (widget.neededPosition.contains(
                                            "Department Extension Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Department Extension Coordinator',
                                        child: Text(
                                            'Department Extension Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Budget Officer/Property Custodian' ||
                                      selectedPosition3 !=
                                          'Budget Officer/Property Custodian')
                                    if (widget.neededPosition.contains(
                                            "Budget Officer/Property Custodian") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Budget Officer/Property Custodian',
                                        child: Text(
                                            'Budget Officer/Property Custodian'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department BSCE Research Coordinator' ||
                                      selectedPosition3 !=
                                          'Department BSCE Research Coordinator')
                                    if (widget.neededPosition.contains(
                                            "Department BSCE Research Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Department BSCE Research Coordinator',
                                        child: Text(
                                            'Department BSCE Research Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'GAD Coordinator' ||
                                      selectedPosition3 != 'GAD Coordinator')
                                    if (widget.neededPosition
                                            .contains("GAD Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'GAD Coordinator',
                                        child: Text('GAD Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'In-Charge Knowledge Management Unit' ||
                                      selectedPosition3 !=
                                          'In-Charge Knowledge Management Unit')
                                    if (widget.neededPosition.contains(
                                            "In-Charge Knowledge Management Unit") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'In-Charge Knowledge Management Unit',
                                        child: Text(
                                            'In-Charge Knowledge Management Unit'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Program Coordinator, BS Archi' ||
                                      selectedPosition3 !=
                                          'Program Coordinator, BS Archi')
                                    if (widget.neededPosition.contains(
                                            "Program Coordinator, BS Archi") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Program Coordinator, BS Archi',
                                        child: Text(
                                            'Program Coordinator, BS Archi'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Research Coordinator, BS Archi' ||
                                      selectedPosition3 !=
                                          'Research Coordinator, BS Archi')
                                    if (widget.neededPosition.contains(
                                            "Research Coordinator, BS Archi") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Research Coordinator, BS Archi',
                                        child: Text(
                                            'Research Coordinator, BS Archi'),
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
                                    color: Colors.black,
                                    fontFamily: "GothamRnd"),
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
                                    if (selectedPosition1 == value) {
                                      selectedPosition1 = '-';
                                    }

                                    if (selectedPosition2 == value) {
                                      selectedPosition2 = '-';
                                    }
                                  });
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: '-',
                                    child: Text('-'),
                                  ),
                                  //
                                  if (selectedPosition2 !=
                                          'University President' ||
                                      selectedPosition3 !=
                                          'University President')
                                    if (widget.neededPosition
                                            .contains("University President") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'University President',
                                        child: Text('University President'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Vice President for Academic Affairs' ||
                                      selectedPosition3 !=
                                          'Vice President for Academic Affairs')
                                    if (widget.neededPosition.contains(
                                            "Vice President for Academic Affairs") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Vice President for Academic Affairs',
                                        child: Text(
                                            'Vice President for Academic Affairs'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'Dean' ||
                                      selectedPosition3 != 'Dean')
                                    if (widget.neededPosition
                                            .contains("Dean") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Dean',
                                        child: Text('Dean'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Chairperson' ||
                                      selectedPosition3 !=
                                          'Department Chairperson')
                                    if (widget.neededPosition.contains(
                                            "Department Chairperson") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Department Chairperson',
                                        child: Text('Department Chairperson'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'BSCE Program Coordinator' ||
                                      selectedPosition3 !=
                                          'BSCE Program Coordinator')
                                    if (widget.neededPosition.contains(
                                            "BSCE Program Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'BSCE Program Coordinator',
                                        child: Text('BSCE Program Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Secretary' ||
                                      selectedPosition3 !=
                                          'Department Secretary')
                                    if (widget.neededPosition
                                            .contains("Department Secretary") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Department Secretary',
                                        child: Text('Department Secretary'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Job Placement Officer' ||
                                      selectedPosition3 !=
                                          'Job Placement Officer')
                                    if (widget.neededPosition.contains(
                                            "Job Placement Officer") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Job Placement Officer',
                                        child: Text('Job Placement Officer'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'OJT Coordinator' ||
                                      selectedPosition3 != 'OJT Coordinator')
                                    if (widget.neededPosition
                                            .contains("OJT Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'OJT Coordinator',
                                        child: Text('OJT Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department Extension Coordinator' ||
                                      selectedPosition3 !=
                                          'Department Extension Coordinator')
                                    if (widget.neededPosition.contains(
                                            "Department Extension Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Department Extension Coordinator',
                                        child: Text(
                                            'Department Extension Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Budget Officer/Property Custodian' ||
                                      selectedPosition3 !=
                                          'Budget Officer/Property Custodian')
                                    if (widget.neededPosition.contains(
                                            "Budget Officer/Property Custodian") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Budget Officer/Property Custodian',
                                        child: Text(
                                            'Budget Officer/Property Custodian'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Department BSCE Research Coordinator' ||
                                      selectedPosition3 !=
                                          'Department BSCE Research Coordinator')
                                    if (widget.neededPosition.contains(
                                            "Department BSCE Research Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'Department BSCE Research Coordinator',
                                        child: Text(
                                            'Department BSCE Research Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 != 'GAD Coordinator' ||
                                      selectedPosition3 != 'GAD Coordinator')
                                    if (widget.neededPosition
                                            .contains("GAD Coordinator") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'GAD Coordinator',
                                        child: Text('GAD Coordinator'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'In-Charge Knowledge Management Unit' ||
                                      selectedPosition3 !=
                                          'In-Charge Knowledge Management Unit')
                                    if (widget.neededPosition.contains(
                                            "In-Charge Knowledge Management Unit") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value:
                                            'In-Charge Knowledge Management Unit',
                                        child: Text(
                                            'In-Charge Knowledge Management Unit'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Program Coordinator, BS Archi' ||
                                      selectedPosition3 !=
                                          'Program Coordinator, BS Archi')
                                    if (widget.neededPosition.contains(
                                            "Program Coordinator, BS Archi") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Program Coordinator, BS Archi',
                                        child: Text(
                                            'Program Coordinator, BS Archi'),
                                      ),
                                  //
                                  if (selectedPosition2 !=
                                          'Research Coordinator, BS Archi' ||
                                      selectedPosition3 !=
                                          'Research Coordinator, BS Archi')
                                    if (widget.neededPosition.contains(
                                            "Research Coordinator, BS Archi") ==
                                        true)
                                      const DropdownMenuItem<String>(
                                        value: 'Research Coordinator, BS Archi',
                                        child: Text(
                                            'Research Coordinator, BS Archi'),
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
                                    color: Colors.black,
                                    fontFamily: "GothamRnd"),
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
              onPressed: () async {
                await provider.updloadImage(index);
                getLink = provider.imgURL;
                _onDone();
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true);
              },
              child: const Icon(Icons.done),
            ),
          ),
        );
      }),
    );
  }
}

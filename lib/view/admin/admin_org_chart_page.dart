import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({Key? key}) : super(key: key);

  @override
  _OrgChartPageState createState() => _OrgChartPageState();
}

class _OrgChartPageState extends State<OrgChartPage> {
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

  _onDone() {
    var name = nameController.text;
    var pos1 = position1Controller.text;
    var faculty = facultyController.text;
    var pos2 = position2Controller.text;
    var pos3 = position3Controller.text;

    FirebaseDatabase.instance.ref('organizationChart/$index').set({
      'id': index,
      'name': name,
      'position1': pos1,
      'faculty': faculty,
      'position2': pos2,
      'position3': pos3,
    });
    nameController.text = "";
    position1Controller.clear();
    facultyController.clear();
    position2Controller.clear();
    position3Controller.clear();
  }

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
    return Scaffold(
      appBar: AppBar(),
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
                  value: null,
                  decoration: const InputDecoration(labelText: 'Position 1'),
                  onChanged: (value) {
                    position1Controller.text = value!;
                  },
                  items: const [
                    DropdownMenuItem<String>(
                      value: '1 to 18 years old',
                      child: Text('1 to 18 years old'),
                    ),
                    DropdownMenuItem<String>(
                      value: '19 to 24 years old',
                      child: Text('19 to 24 years old'),
                    ),
                    DropdownMenuItem<String>(
                      value: '25 to 35 years old',
                      child: Text('25 to 35 years old'),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: null,
                  decoration: const InputDecoration(labelText: 'Position 2'),
                  onChanged: (value) {
                    position2Controller.text = value!;
                  },
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Position 1',
                      child: Text('Position 1'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Position 2',
                      child: Text('Position 2'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Position 3',
                      child: Text('Position 3'),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: null,
                  decoration: const InputDecoration(labelText: 'Position 3'),
                  onChanged: (value) {
                    position3Controller.text = value!;
                  },
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Position 1',
                      child: Text('Position 1'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Position 2',
                      child: Text('Position 2'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Position 3',
                      child: Text('Position 3'),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: null,
                  decoration: const InputDecoration(labelText: 'Faculty'),
                  onChanged: (value) {
                    facultyController.text = value!;
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
    );
  }
}

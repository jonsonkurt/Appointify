import 'package:flutter/material.dart';

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({Key? key}) : super(key: key);

  @override
  _OrgChartPageState createState() => _OrgChartPageState();
}

class _OrgChartPageState extends State<OrgChartPage> {
  var nameTECs = <TextEditingController>[];
  var position1 = <TextEditingController>[];
  var facultyTECs = <TextEditingController>[]; // List for faculty controllers
  var position2 = <TextEditingController>[]; // List for position controllers
  var position3 = <TextEditingController>[];
  // List for height controllers
  var cards = <Card>[];

  Card createCard(int index) {
    var nameController = TextEditingController();
    var position1Controller = TextEditingController();
    var facultyController = TextEditingController(); // Controller for faculty
    var position2Controller = TextEditingController();
    var position3Controller = TextEditingController();

    nameTECs.add(nameController);
    position1.add(position1Controller);
    facultyTECs.add(facultyController); // Add faculty controller to the list
    position2.add(position2Controller);
    position3.add(position3Controller); // Add position controller to the list
    // Add height controller to the list
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteCard(index),
              ),
            ],
          ),
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
    );
  }

  @override
  void initState() {
    super.initState();
    cards.add(createCard(0));
  }

  void _deleteCard(int index) {
    setState(() {
      cards.removeAt(index);
      nameTECs.removeAt(index);
      position1.removeAt(index);
      facultyTECs.removeAt(index); // Remove faculty controller
      position2.removeAt(index);
      position3.removeAt(index);
      // Remove position controller
      // Remove height controller
    });
  }

  _onDone() {
    List<Map<String, String>> entries = [];
    for (int i = 0; i < cards.length; i++) {
      var name = nameTECs[i].text;
      var pos1 = position1[i].text;
      var faculty = facultyTECs[i].text; // Get faculty value
      var pos2 = position2[i].text; // Get position value
      var pos3 = position3[i].text; // Get position value
      // Get height value
      entries.add({
        'name': name,
        'position1': pos1,
        'faculty': faculty,
        'position2': pos2,
        'position3': pos3,
      });
    }
    print(PersonEntry(entries));
    //Navigator.pop(context, PersonEntry(entries));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (BuildContext context, int index) {
                return cards[index];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: const Text('Add new'),
              onPressed: () =>
                  setState(() => cards.add(createCard(cards.length))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.done),
        onPressed: _onDone,
      ),
    );
  }
}

class PersonEntry {
  final List<Map<String, String>> entries;

  PersonEntry(this.entries);

  @override
  String toString() {
    return 'Person Entries: ${entries.runtimeType}';
  }
}

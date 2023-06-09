import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfessorProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String professorRole;
  final String status;
  final String availability;

  const ProfessorProfilePage({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.professorRole,
    required this.status,
    required this.availability,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfessorProfilePageState createState() => _ProfessorProfilePageState();
}

class _ProfessorProfilePageState extends State<ProfessorProfilePage> {
  late Map<String, dynamic> myDictionary;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    myDictionary = parseStringToMap(widget.availability);
  }

  Map<String, dynamic> parseStringToMap(String jsonString) {
    Map<String, dynamic> resultMap = {};

    // Remove curly braces from the string
    String cleanedString = jsonString.replaceAll('{', '').replaceAll('}', '');

    // Split the string by commas to get individual key-value pairs
    List<String> keyValuePairs = cleanedString.split(',');

    for (String pair in keyValuePairs) {
      // Split each pair into key and value
      int colonIndex = pair.indexOf(':');
      String key = pair.substring(0, colonIndex).trim();
      String value = pair.substring(colonIndex + 1).trim();

      // If the value is a string, remove leading and trailing quotes
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }

      resultMap[key] = value;
    }

    return resultMap;
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      setState(() {
        if (selectedDate != null) {
          // Update the availability with the selected date
          myDictionary['Selected Date'] = selectedDate.toString();
          _dateController.text = DateFormat.yMMMd('en_US').format(selectedDate);
        }
      });
    });
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((selectedTime) {
      setState(() {
        if (selectedTime != null) {
          // Update the availability with the selected time
          myDictionary['Selected Time'] = selectedTime.format(context);
          _timeController.text = selectedTime.format(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Set an appointment'),
          Image.asset('assets/images/default.png'),
          Text('${widget.firstName} ${widget.lastName}'),
          Text(widget.professorRole),
          Text(widget.status),
          for (var entry in myDictionary.entries)
            Text('${entry.key}: ${entry.value}'),
          const Divider(
            thickness: 3,
            color: Colors.black,
          ),
          TextField(
            controller: _dateController,
            onTap: _showDatePicker,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Select Date',
            ),
          ),
          TextField(
            controller: _timeController,
            onTap: _showTimePicker,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Select Time',
            ),
          ),
          // Add more profile information widgets as needed
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProfessorProfilePage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String professorRole;
  final String status;
  final String availability;

  const ProfessorProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.professorRole,
    required this.status,
    required this.availability,
  });

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

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> myDictionary = parseStringToMap(availability);
    print(myDictionary['Monday']);
    return Scaffold(
      body: Column(
        children: [
          const Text('Set an appointment'),
          Image.asset('assets/images/default.png'),
          Text('$firstName $lastName'),
          Text(professorRole),
          Text(status),
          for (var entry in myDictionary.entries)
            Text('${entry.key}  ${entry.value}'),
          Divider(
            thickness: 3,
            color: Colors.black,
          ),
          // Add more profile information widgets as needed
        ],
      ),
    );
  }
}

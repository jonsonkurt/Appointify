import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class ProfessorPage extends StatefulWidget {
  const ProfessorPage({super.key});

  @override
  State<ProfessorPage> createState() => _ProfessorPageState();
}

class _ProfessorPageState extends State<ProfessorPage> {
  var logger = Logger();
  String realTimeValue = "";
  String? userID = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  String name = '';
  StreamSubscription<DatabaseEvent>? nameSubscription;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _handleButtonPress() {
    // Handle button press logic
    print('Button clicked!');
  }

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );

    DatabaseReference appointmentsRef = rtdb.ref('professors/');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          const Text(
            'Professors',
          ),
          const Divider(
            color: Colors.black,
            thickness: 3,
          ),
          SearchBox(onSearch: _handleSearch),
          Expanded(
              child: FirebaseAnimatedList(
            query: appointmentsRef,
            itemBuilder: (context, snapshot, animation, index) {
              String profFirstName =
                  snapshot.child('firstName').value.toString();
              String profLastName = snapshot.child('lastName').value.toString();
              String status = snapshot.child('status').value.toString();
              // Filter professors based on the entered name
              if (name.isNotEmpty &&
                  !profFirstName.toLowerCase().contains(name.toLowerCase()) &&
                  !profLastName.toLowerCase().contains(name.toLowerCase())) {
                return Container(); // Hide the professor card if it doesn't match the search criteria
              }
              return Card(
                  child: Column(
                children: [
                  Text('$profFirstName $profLastName'),
                  Text(snapshot.child('professorRole').value.toString()),
                  Text(snapshot.child('status').value.toString()),
                  ElevatedButton(
                    onPressed:
                        status == 'accepting' ? _handleButtonPress : null,
                    child: const Text('Appointment'),
                  )
                ],
              ));
            },
          ))
        ]),
      ),
    );
  }
}

class SearchBox extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const SearchBox({required this.onSearch, Key? key}) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onSearch,
    );
  }
}
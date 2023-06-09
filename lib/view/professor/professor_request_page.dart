import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
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

  void _handleButtonPress(String firstName, String lastName,
      String professorRole, String status, String availability) {
    // INSERT CODE FOR NEW PAGE
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ProfessorProfilePage(
    //       firstName: firstName,
    //       lastName: lastName,
    //       professorRole: professorRole,
    //       status: status,
    //       availability: availability,
    //     ),
    //   ),
    // );
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

    DatabaseReference appointmentsRef = rtdb.ref('appointments/');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          const Text(
            'Requests',
          ),
          const Divider(
            color: Colors.black,
            thickness: 3,
          ),
          SearchBox(onSearch: _handleSearch),
          Expanded(
              child: FirebaseAnimatedList(
            query: appointmentsRef
                .orderByChild('requestStatusProfessor')
                .equalTo("$userID-PENDING"),
            itemBuilder: (context, snapshot, animation, index) {
              // Modify strings based on your needs
              String studentName =
                  snapshot.child('studentName').value.toString();

              // Filter professors based on the entered name
              if (name.isNotEmpty &&
                  !studentName.toLowerCase().contains(name.toLowerCase())) {
                return Container(); // Hide the professor card if it doesn't match the search criteria
              }

              return Card(
                  child: Column(
                children: [
                  Text(snapshot.child('studentName').value.toString()),
                  Text(snapshot.child('studentSection').value.toString()),
                  Text(snapshot.child('date').value.toString()),
                  Text(snapshot.child('time').value.toString()),

                  // Modify button based on what you need
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      // Add your desired functionality here
                    },
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      // Add your desired functionality here
                    },
                    child: const Text('Reschedule'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      // Add your desired functionality here
                    },
                    child: const Text('Reject'),
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
  // ignore: library_private_types_in_public_api
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

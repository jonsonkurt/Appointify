import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'professor_profile_page.dart';
import 'package:appointify/view/student/profile_controller.dart';

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
  bool isEmptyProfessor = true;
  String name = '';
  StreamSubscription<DatabaseEvent>? nameSubscription,
      emptyProfessorSubscription;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  @override
  void dispose() {
    nameSubscription?.cancel();
    emptyProfessorSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _handleButtonPress(
      String firstName,
      String lastName,
      String professorRole,
      String status,
      String availability,
      String professorID,
      String salutation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessorProfilePage(
          firstName: firstName,
          lastName: lastName,
          professorRole: professorRole,
          status: status,
          availability: availability,
          professorID: professorID,
          salutation: salutation,
        ),
      ),
    );
  }

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Database reference and query for empty view
    DatabaseReference emptyProfessorRef =
        FirebaseDatabase.instance.ref('professors');
    Query emptyProfessorQuery = emptyProfessorRef.orderByChild('firstName');

    emptyProfessorSubscription = emptyProfessorQuery.onValue.listen((event) {
      try {
        if (mounted) {
          setState(() {
            String check = event.snapshot.value.toString();
            if (check != "null") {
              isEmptyProfessor = false;
            }
          });
        }
      } catch (error, stackTrace) {
        logger.d('Error occurred: $error');
        logger.d('Stack trace: $stackTrace');
      }
    });

    DatabaseReference appointmentsRef =
        FirebaseDatabase.instance.ref('professors/');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          return false; // Disable back button
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF274C77),
            title: const Text(
              "Employees",
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'GothamRnd',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const SizedBox(
                width: 350,
              ),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF274C77),
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  // Set the background color of the box
                  // Set the border radius of the box
                ),
                child: const Divider(
                  color: Colors.white,
                  thickness: 1.5,
                  indent: 20,
                  endIndent: 20,
                ),
              ),
              SearchBox(onSearch: _handleSearch),
              const SizedBox(
                height: 10,
              ),
              if (isEmptyProfessor)
                const SizedBox(
                  // color: Colors.red,
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No Available Data",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "GothamRnd"),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!isEmptyProfessor)
                Expanded(
                    child: FirebaseAnimatedList(
                  query: appointmentsRef.orderByChild("firstName"),
                  itemBuilder: (context, snapshot, animation, index) {
                    String availability =
                        snapshot.child('availability').value.toString();

                    String profFirstName =
                        snapshot.child('firstName').value.toString();
                    String profLastName =
                        snapshot.child('lastName').value.toString();
                    String status = snapshot.child('status').value.toString();
                    String employmentStatus =
                        snapshot.child('employmentStatus').value.toString();
                    // Filter professors based on the entered name

                    if (name.isNotEmpty &&
                        !profFirstName
                            .toLowerCase()
                            .contains(name.toLowerCase()) &&
                        !profLastName
                            .toLowerCase()
                            .contains(name.toLowerCase())) {
                      return Container(); // Hide the professor card if it doesn't match the search criteria
                    }
                    if (employmentStatus == "Resigned") {
                      return Container();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 10,
                      ),
                      child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 15,
                                        left: 15,
                                        right: 15,
                                        bottom: 5,
                                      ),
                                      child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFA2C2FF),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: ProfileController().image ==
                                                    null
                                                ? snapshot
                                                            .child(
                                                                'profilePicStatus')
                                                            .value
                                                            .toString() ==
                                                        "None"
                                                    ? const Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 25,
                                                      )
                                                    : Image(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(snapshot
                                                            .child(
                                                                'profilePicStatus')
                                                            .value
                                                            .toString()),
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return const CircularProgressIndicator();
                                                        },
                                                        errorBuilder: (context,
                                                            object, stack) {
                                                          return const Icon(
                                                            Icons.error_outline,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    35,
                                                                    35,
                                                                    35),
                                                          );
                                                        },
                                                      )
                                                : Image.file(File(
                                                        ProfileController()
                                                            .image!
                                                            .path)
                                                    .absolute)),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$profFirstName $profLastName',
                                        style: const TextStyle(
                                          fontFamily: "GothamRnd",
                                          color: Color(0xFF393838),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        snapshot
                                            .child('professorRole')
                                            .value
                                            .toString(),
                                        style: const TextStyle(
                                          fontFamily: "GothamRnd-Light",
                                          color: Color(0xFF393838),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                                thickness: 1.2,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 20),
                                        const Icon(
                                          Icons.event_available,
                                          color: Colors.black,
                                        ),
                                        Text(
                                          snapshot
                                              .child('status')
                                              .value
                                              .toString(),
                                          style: const TextStyle(
                                            fontFamily: "GothamRnd-Bold",
                                            color: Color(0xFF393838),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.add,
                                        size: 15,
                                      ),
                                      label: const Text(
                                        'Appointment',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "GothamRnd-Light",
                                          fontSize: 12,
                                        ),
                                      ),
                                      onPressed: status == 'accepting'
                                          ? () => _handleButtonPress(
                                                profFirstName,
                                                profLastName,
                                                snapshot
                                                    .child('professorRole')
                                                    .value
                                                    .toString(),
                                                snapshot
                                                    .child('status')
                                                    .value
                                                    .toString(),
                                                availability,
                                                snapshot
                                                    .child('profUserID')
                                                    .value
                                                    .toString(),
                                                snapshot
                                                    .child('salutation')
                                                    .value
                                                    .toString(),
                                              )
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(130, 10),
                                        backgroundColor:
                                            const Color(0xFF6096BA),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              5), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    );
                  },
                ))
            ]),
          ),
        ),
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
    return Container(
      width: double.infinity,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF274C77), // Set the background color of the box
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        // Set the border radius of the box
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: 10,
            left: MediaQuery.of(context).size.width / 20,
            right: MediaQuery.of(context).size.width / 20),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search',
            hintStyle: TextStyle(fontFamily: "GothamRnd", color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Color(0xFF6096BA)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: widget.onSearch,
        ),
      ),
    );
  }
}

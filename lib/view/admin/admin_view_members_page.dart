import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:appointify/view/student/profile_controller.dart';

class AdminViewMembers extends StatefulWidget {
  const AdminViewMembers({Key? key}) : super(key: key);

  @override
  State<AdminViewMembers> createState() => _AdminViewMembers();
}

class _AdminViewMembers extends State<AdminViewMembers> {
  var logger = Logger();
  // String realTimeValue = "";
  // String? userID = FirebaseAuth.instance.currentUser?.uid;
  // bool isLoading = true;
  // String name = '';
  // StreamSubscription<DatabaseEvent>? nameSubscription;

  String name = '';

  void _handleSearch(String value) {
    setState(() {
      name = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference professorRef =
        FirebaseDatabase.instance.ref('organizationChart/');

    return WillPopScope(
      onWillPop: () async {
        return false; // Disable back button
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Members"),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Divider(
                indent: 30,
                endIndent: 30,
                thickness: 2,
                color: Colors.black,
              ),
              const SizedBox(height: 15),
              SearchBox(
                onSearch: _handleSearch,
              ),
              Expanded(
                  child: FirebaseAnimatedList(
                      query: professorRef,
                      itemBuilder: (context, snapshot, animation, index) {
                        String name1 = snapshot.child('name').value.toString();
                        String? position1 =
                            snapshot.child('position1').value.toString();
                        String position2 =
                            snapshot.child('position2').value.toString();
                        String position3 =
                            snapshot.child('position3').value.toString();
                        String faculty =
                            snapshot.child('faculty').value.toString();

                        if (name.isNotEmpty &&
                            !name1.toLowerCase().contains(name.toLowerCase()) &&
                            !name1.toLowerCase().contains(name.toLowerCase())) {
                          return Container(); // Hide the professor card if it doesn't match the search criteria
                        }

                        if (position1 != "test") {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.only(
                                top: 10,
                                left: 30,
                                right: 30,
                              ),
                              color: const Color(0xFFDCDAD8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 10),
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
                                                        size: 35,
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
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 5),
                                          child: Text(
                                            name1,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontFamily: "GothamRnd",
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (position1.isNotEmpty)
                                          Text(
                                            position1,
                                            style: const TextStyle(
                                              fontFamily: "GothamRnd-Light",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        if (position2.isNotEmpty)
                                          Text(
                                            position2,
                                            style: const TextStyle(
                                              fontFamily: "GothamRnd-Light",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        if (position3.isNotEmpty)
                                          Text(
                                            position3,
                                            style: const TextStyle(
                                              fontFamily: "GothamRnd-Light",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        if (faculty.isNotEmpty)
                                          Text(
                                            faculty,
                                            style: const TextStyle(
                                              fontFamily: "GothamRnd-Light",
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  print("this is edit button");
                                                },
                                                icon: Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () {
                                                  print(
                                                      "this is delete button");
                                                },
                                                icon: Icon(Icons.delete)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        }
                        return Text("");
                      }))
            ],
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
    return Center(
      child: SafeArea(
        child: SizedBox(
          width: 350,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: const TextStyle(
                fontFamily: "GothamRnd",
                fontSize: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xff274C77), width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xff274C77), width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xff274C77),
              ),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(20),
              )),
            ),
            onChanged: widget.onSearch,
          ),
        ),
      ),
    );
  }
}

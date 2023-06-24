import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:appointify/view/student/profile_controller.dart';
import 'admin_edit_members.dart';

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
          elevation: 0,
          backgroundColor: const Color(0xFF274C77),
          title: const Text(
            "Members",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: "GothamRnd",
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color:
                      Color(0xFF274C77), // Set the background color of the box
                  // Set the border radius of the box
                ),
                child: const Divider(
                  color: Colors.white,
                  thickness: 1.5,
                  indent: 25,
                  endIndent: 25,
                ),
              ),
              SearchBox(
                onSearch: _handleSearch,
              ),
              const SizedBox(height: 15),
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
                    String faculty = snapshot.child('faculty').value.toString();
                    String id = snapshot.child('id').value.toString();

                    if (name.isNotEmpty &&
                        !name1.toLowerCase().contains(name.toLowerCase()) &&
                        !name1.toLowerCase().contains(name.toLowerCase())) {
                      return Container(); // Hide the professor card if it doesn't match the search criteria
                    }

                    if (position1 != "test") {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height / 90,
                        ),
                        child: Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 90,
                            left: MediaQuery.of(context).size.width / 20,
                            right: MediaQuery.of(context).size.width / 20,
                          ),
                          color: const Color(0xFFDCDAD8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                9,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
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
                                                            .child('imageURL')
                                                            .value
                                                            .toString() ==
                                                        ""
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 35,
                                                      )
                                                    : Image(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            snapshot
                                                                .child(
                                                                    'imageURL')
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
                                    if (faculty.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          faculty,
                                          style: TextStyle(
                                            fontFamily: "GothamRnd-Light",
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 5),
                                        child: Opacity(
                                          opacity:
                                              0.9, // Adjust the opacity value as desired
                                          child: Text(
                                            name1,
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  25,
                                              fontFamily: "GothamRnd",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                          ),
                                        ),
                                      ),
                                      if (position1.isNotEmpty)
                                        Text(
                                          position1,
                                          style: TextStyle(
                                            fontFamily: "GothamRnd-Light",
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      if (position2.isNotEmpty)
                                        Text(
                                          position2,
                                          style: TextStyle(
                                            fontFamily: "GothamRnd-Light",
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      if (position3.isNotEmpty)
                                        Text(
                                          position3,
                                          style: TextStyle(
                                            fontFamily: "GothamRnd-Light",
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                35,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          // ElevatedButton(
                                          //   style: ElevatedButton.styleFrom(
                                          //     fixedSize: const Size(100, 20),
                                          //     backgroundColor:
                                          //         const Color(0xFF274C77),
                                          //     shape: RoundedRectangleBorder(
                                          //       borderRadius:
                                          //           BorderRadius.circular(
                                          //               10), // Adjust the radius as needed
                                          //     ),
                                          //   ),
                                          //   onPressed: () {
                                          //     Navigator.push(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //             builder: (context) =>
                                          //                 EditOrgChartPage(
                                          //                     empName: name1,
                                          //                     empPos1:
                                          //                         position1,
                                          //                     empPos2:
                                          //                         position2,
                                          //                     empPos3:
                                          //                         position3,
                                          //                     empFaculty:
                                          //                         faculty,
                                          //                     empID: id)));
                                          //   },
                                          //   child: const Text(
                                          //     'Edit',
                                          //     style: TextStyle(
                                          //       fontFamily: "GothamRnd",
                                          //       color: Colors.white,
                                          //       fontSize: 15,
                                          //     ),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   width: MediaQuery.of(context)
                                          //           .size
                                          //           .width /
                                          //       25,
                                          // ),

                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              fixedSize: const Size(100, 20),
                                              backgroundColor:
                                                  const Color(0xFF274C77),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    10), // Adjust the radius as needed
                                              ),
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Are you sure you want to remove this member?'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text(
                                                          'Confirm',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "GothamRnd"),
                                                        ),
                                                        onPressed: () async {
                                                          await professorRef
                                                              .child(id)
                                                              .remove();
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "GothamRnd"),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontFamily: "GothamRnd",
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      );
                    }
                    return const Text("");
                  },
                ),
              )
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
        child: Container(
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
                top: MediaQuery.of(context).size.height / 50,
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
                hintStyle:
                    TextStyle(fontFamily: "GothamRnd", color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6096BA)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: widget.onSearch,
            ),
          ),
        ),
      ),
    );
  }
}

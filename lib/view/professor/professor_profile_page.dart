import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'admin_profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }
  @override
  void dispose() {
    nameSubscription?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Redirect the user to the SignInPage after logging out
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  final ref = FirebaseDatabase.instance.ref('professors');

  @override
  Widget build(BuildContext context) {
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
      app: firebaseApp,
      databaseURL:
          'https://appointify-388715-default-rtdb.asia-southeast1.firebasedatabase.app/',
    );

    DatabaseReference employeesRef = rtdb.ref('professors');
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: ChangeNotifierProvider(
              create: (_) => AdminProfileController(),
              child: Consumer<AdminProfileController>(
                builder: (context, provider, child) {
                  return SafeArea(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: StreamBuilder(
                        stream: employeesRef.child(userID!).onValue,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasData) {
                            Map<dynamic, dynamic> map =
                                snapshot.data.snapshot.value;
                            String firstName = map['firstName'];
                            String lastName = map['lastName'];
                            String designation = map['designation'];
                            String professorRole = map['professorRole'];
                            String salutation = map['salutation'];
                            String status = map['status'];
                            String profilePicStatus = map['profilePicStatus'].toString();

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Profile page Text
                                  const Text("Employee Profile"),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    child: Center(
                                      child: Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 35, 35, 35),
                                              width: 2,
                                            )),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: provider.image == null ?  map['profilePicStatus'].toString() =="None" ? const Icon(Icons.person, size: 35,):
                                                Image(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  profilePicStatus),
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const CircularProgressIndicator();
                                              },
                                              errorBuilder:
                                                  (context, object, stack) {
                                                return const Icon(
                                                  Icons.error_outline,
                                                  color: Color.fromARGB(
                                                      255, 35, 35, 35),
                                                );
                                              },
                                            ) :
    
                                            Image.file(
                                              File(provider.image!.path).absolute
                                            )
    
    
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ReuseableRow(
                                      title: 'Name',
                                      value: '$firstName $lastName',
                                      iconData: Icons.person_outline),
                                  ReuseableRow(
                                      title: 'Email',
                                      value: salutation,
                                      iconData: Icons.email),
                                  ReuseableRow(
                                      title: 'Position',
                                      value: professorRole,
                                      iconData: Icons.account_box),
                                  ReuseableRow(
                                      title: 'Designation',
                                      value: designation,
                                      iconData: Icons.assignment_ind),
                                  ReuseableRow(
                                      title: 'Status',
                                      value: status,
                                      iconData: Icons.check_box),
    
                                  //update profile button
                                  Center(
                                    // update prolife logic
                                    child: ElevatedButton(
                                      onPressed: () {
                                        provider.pickImage(context);
                                      },
                                      child: const Text('Update Profile Picture'),
                                    ),
                                  ),
    
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _logout,
                                    child: const Text("Logout"),
                                  ),
                                ]);
                          } else {
                            return const Center(
                                child: Text('Something went wrong.'));
                          }
                        }),
                  ));
                },
              ))),


      // home: Scaffold(
      //   body: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const Text("Profile Page"),
      //         const SizedBox(height: 20),
      //         ElevatedButton(
      //           onPressed: _logout,
      //           child: const Text("Logout"),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
  
}

class ReuseableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;
  const ReuseableRow(
      {super.key,
      required this.title,
      required this.value,
      required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: Icon(iconData),
          trailing: Text(value),
        ),
        const Divider(
          color: Color.fromARGB(255, 35, 35, 35),
        ),
      ],
    );
  }
}

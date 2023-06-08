import 'package:appointify/view/student/storage_queries.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    // Redirect the user to the SignInPage after logging out
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          //Profile page Text
          const Text("Profile Page"),

          // download or retrieved image from cloud and display it
          FutureBuilder(
              future: storage.downloadURL(userID.toString()),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return CircleAvatar(
                    radius: ((MediaQuery.of(context).size.height * .1) +
                        3), // Change this radius for the width of the circular border
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                        radius: MediaQuery.of(context).size.height *
                            .1, // This radius is the radius of the picture in the circle avatar itself.
                        backgroundImage: NetworkImage(
                          snapshot.data!,
                        )),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Container();
              }),

          //update profile button
          Center(
            // update prolife logic
            child: ElevatedButton(
              onPressed: () async {
                final results = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg'],
                );
                if (results == null) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No file selected.'),
                  ));
                  return;
                }
                final String path = results.files.single.path.toString();
                // final String fileName = results.files.single.name;
                storage.uploadFile(path, '$userID.jpg');
              },
              child: const Text('Update Profile'),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _logout,
            child: const Text("Logout"),
          ),
        ]),
      ),
    );
  }
}

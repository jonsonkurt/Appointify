import 'package:appointify/view/student/storage_upload.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointify/view/sign_in_page.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          Center(
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
                final String fileName = results.files.single.name;

                storage.uploadFile(path, fileName);
              },
              child: const Text('Upload File'),
            ),
          ),
          FutureBuilder(
              future: storage.listFiles(),
              builder: (BuildContext context,
                  AsyncSnapshot<firebase_storage.ListResult> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    height: 50,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text(snapshot.data!.items[index].name),
                            ),
                          );
                        }),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return Container();
              }),
          FutureBuilder(
              future: storage.downloadURL('sticker_1.png'),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    width: 300,
                    height: 250,
                    child: Image.network(
                      snapshot.data!, 
                      fit: BoxFit.cover,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return Container();
              }),
          const Text("Profile Page"),
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

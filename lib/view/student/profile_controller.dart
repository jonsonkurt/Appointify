import 'dart:io';
import 'package:appointify/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart';

class ProfileController with ChangeNotifier {
  final picker = ImagePicker();

  String? userID = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('students');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  XFile? _image;
  XFile? get image => _image;
  String imgURL = '';

  Future pickGalleryImage(BuildContext context) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      notifyListeners();
      // ignore: use_build_context_synchronously
      updloadImage(context);
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      notifyListeners();
      // ignore: use_build_context_synchronously
      updloadImage(context);
    }
  }

  void pickImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () async {
                        if (await Permission.camera.request().isGranted) {
                          // ignore: use_build_context_synchronously
                          pickCameraImage(context);
                        } else {
                          await cameraPermission();
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      leading: const Icon(
                        Icons.camera,
                        color: Color.fromARGB(255, 35, 35, 35),
                      ),
                      title: const Text('Camera'),
                    ),
                    ListTile(
                      onTap: () async {
                        if (await Permission.storage.request().isGranted) {
                          // ignore: use_build_context_synchronously
                          pickGalleryImage(context);
                        } else {
                          await storagePermission();
                        }

                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      leading: const Icon(
                        Icons.image,
                        color: Color.fromARGB(255, 35, 35, 35),
                      ),
                      title: const Text('Gallery'),
                    ),
                  ],
                )),
          );
        });
  }

  void updloadImage(BuildContext context) async {
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.ref('studentProfile/$userID');
    firebase_storage.UploadTask uploadTask =
        storageRef.putFile(File(image!.path).absolute);
    await Future.value(uploadTask);

    imgURL = await storageRef.getDownloadURL();

    // ref
    //     .child(userID.toString())
    //     .update({'profilePicStatus': newUrl.toString()}).then((value) {
    //   _image = null;
    // }).onError((error, stackTrace) {
    //   //insert toast here
    // });
  }
}

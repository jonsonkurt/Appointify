import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  // Create a storage reference from our app
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await storage.ref('studentProfile/$fileName').putFile(file);
    // ignore: empty_catches
    } on firebase_core.FirebaseException {
      
    }
  }

  Future<firebase_storage.ListResult> listFiles() async {
    firebase_storage.ListResult results =
        await storage.ref("studentProfile").listAll();

    // ignore: unused_local_variable
    for (var ref in results.items) {
    }
    return results;
  }

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL =
          await storage.ref('studentProfile/$imageName.jpg').getDownloadURL();
          return downloadURL;
          
    } on firebase_core.FirebaseException {
          String downloadURL = await storage.ref('studentProfile/default_image.png').getDownloadURL();
          return downloadURL;
    }

    
  }
}

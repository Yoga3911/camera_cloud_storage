import 'dart:io';

import 'package:camera_cloud_storage/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _subtitle = TextEditingController();

  final key = GlobalKey<FormState>();

  File? file;
  String? imageUrl;
  String? imageName;
  void getFromCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      final result = await ImagePicker().pickImage(source: ImageSource.camera);
      if (result != null) {
        file = File(result.path);
        imageName = result.name;
      }
    }

    setState(() {});
  }

  void getFromGallery() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      file = File(result.path);
      imageName = result.name;
    }

    setState(() {});
  }

  Future<void> uploadImage() async {
    await FirebaseService.storage.ref("products/$imageName").putFile(file!);
  }

  Future<String> getUrlImage() async {
    final result = await FirebaseService.storage
        .ref("products/$imageName")
        .getDownloadURL();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
      ),
      body: Form(
        key: key,
        child: ListView(
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                label: Text("Title"),
              ),
              validator: (value) {
                if (value == "") {
                  return "Title tidak boleh kosong";
                }

                return null;
              },
            ),
            TextFormField(
              controller: _subtitle,
              decoration: const InputDecoration(
                label: Text("Subtitle"),
              ),
              validator: (value) {
                if (value == "") {
                  return "Subtitle tidak boleh kosong";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: file == null
                  ? Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                        ),
                      ),
                    )
                  : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        image: DecorationImage(
                          image: FileImage(file!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    getFromCamera();
                  },
                  icon: const Icon(Icons.camera),
                ),
                IconButton(
                  onPressed: () {
                    getFromGallery();
                  },
                  icon: const Icon(Icons.image),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (key.currentState!.validate()) {
                  uploadImage().then((value) async {
                    final url = await getUrlImage();
                    FirebaseService.products.add({
                      "title": _title.text,
                      "subtitle": _subtitle.text,
                      "image_url": url,
                    }).then(
                      (value) => Navigator.pop(context),
                    );
                  });
                }
                return;
              },
              child: const Text("Insert"),
            )
          ],
        ),
      ),
    );
  }
}

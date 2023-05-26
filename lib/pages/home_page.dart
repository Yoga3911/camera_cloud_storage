import 'package:camera_cloud_storage/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Camera & Cloud Storage"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.products.snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: (snapshot.data?.docs ?? [])
                .map(
                  (e) => productTile(
                    title: e["title"],
                    subtitle: e["subtitle"],
                    image_url: e["image_url"],
                  ),
                )
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddProductPage(),
          ),
        ),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  ListTile productTile(
      {required String title,
      required String subtitle,
      required String image_url}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: image_url == ""
          ? const CircleAvatar()
          : CircleAvatar(
              backgroundImage: NetworkImage(image_url),
            ),
    );
  }
}

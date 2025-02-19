import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("Circulars");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty News'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<Map<String, dynamic>> circulars = [];

            data.forEach((key, value) {

              if (value is Map && value["faculty_rev"] == true) {
                circulars.add({
                  "title": value["title"] ?? "No Title",
                  "description": value["description"] ?? "No Description",
                  "date": value["published_date"] ?? "Unknown Date",
                });
              }
            });

            if (circulars.isEmpty) {
              return const Center(child: Text("No faculty circulars available."));
            }

            return ListView.builder(
              itemCount: circulars.length,
              itemBuilder: (context, index) {
                final circular = circulars[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.blue),
                    title: Text(circular['title']!),
                    subtitle: Text(
                      'Date: ${circular['date']}\n\n${circular['description']}',
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No circulars found."));
          }
        },
      ),
    );
  }
}

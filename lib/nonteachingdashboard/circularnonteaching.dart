import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StaffCircularsPage extends StatefulWidget {
  @override
  _StaffCircularsPageState createState() => _StaffCircularsPageState();
}

class _StaffCircularsPageState extends State<StaffCircularsPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Circulars');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Staff Circulars',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: StreamBuilder(
        stream: _database.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Text(
                'No circulars available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          Map<dynamic, dynamic> circulars = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> staffCirculars = [];

          circulars.forEach((key, value) {
            if (value['staff_rev'] == true) {
              staffCirculars.add({
                'id': key,
                'title': value['title'],
                'description': value['description'],
                'published_date': value['published_date'],
              });
            }
          });

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: staffCirculars.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    staffCirculars[index]['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Text(
                    'Published on: ${staffCirculars[index]['published_date']}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StaffCircularPreview(
                          title: staffCirculars[index]['title'],
                          description: staffCirculars[index]['description'],
                          publishedDate: staffCirculars[index]['published_date'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StaffCircularPreview extends StatelessWidget {
  final String title;
  final String description;
  final String publishedDate;

  StaffCircularPreview({
    required this.title,
    required this.description,
    required this.publishedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Circular Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset("assets/images/logo1.png", height: 150, width: 120),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "NARMADA COLLEGE OF SCIENCE & COMMERCE",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                "Zadeshwar, Bharuch(Gujarat) 392011",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Date: $publishedDate",
              style: TextStyle(fontSize: 14),
            ),
            Divider(thickness: 1, height: 20),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
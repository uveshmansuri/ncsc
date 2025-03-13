import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class StudentCircularsPage extends StatefulWidget {
  @override
  _StudentCircularsPageState createState() => _StudentCircularsPageState();
}

class _StudentCircularsPageState extends State<StudentCircularsPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Circulars');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Circulars', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: _database.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No circulars available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
          }

          Map<dynamic, dynamic> circulars = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> studentCirculars = [];

          circulars.forEach((key, value) {
            if (value['student_rev'] == true) {
              studentCirculars.add({'title': value['title'], 'description': value['description']});
            }
          });

          return ListView.builder(
            itemCount: studentCirculars.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  title: Text(
                    studentCirculars[index]['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                  onTap: () {
                    _showCircularDetails(context, studentCirculars[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCircularDetails(BuildContext context, Map<String, dynamic> circular) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            circular['title'],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          content: SingleChildScrollView(
            child: Text(
              circular['description'],
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}

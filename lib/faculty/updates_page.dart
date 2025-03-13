import 'package:NCSC/faculty/newsforyou.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'addassignment.dart';
import 'alertpage.dart';
import 'circularpage.dart';

class UpdatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [                                       //quizzzzzzzzzzzzzz
            CustomCard(title: "Alert", navigateTo: AlertPage()),
            SizedBox(height: 16),
            CustomCard(title: "News for you", navigateTo:  NewsScreen()),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final Widget navigateTo;

  CustomCard({required this.title, required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navigateTo),
          );
        },
      ),
    );
  }
}

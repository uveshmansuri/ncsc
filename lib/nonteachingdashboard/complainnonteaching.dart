import 'package:flutter/material.dart';

class complainnonteaching extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint - Non Teaching"),
      ),
      body: Center(
        child: Text(
          "Complaint Page for Non-Teaching Staff",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

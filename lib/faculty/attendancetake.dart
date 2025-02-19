import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: Center(child: Text("Attendance Content Here", style: TextStyle(fontSize: 24))),
    );
  }
}

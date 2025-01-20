import 'package:flutter/material.dart';

class StudentManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
      ),
      body: Center(
        child: Text(
          'Student Management Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

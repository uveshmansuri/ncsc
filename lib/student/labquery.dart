import 'package:flutter/material.dart';

class LabQueryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Query'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'This is the Lab Query page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ScienceLabQueryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Science Lab Query'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'This is the Science Lab Query page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

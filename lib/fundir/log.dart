import 'package:flutter/material.dart';

class LogEntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Entry'),
      ),
      body: Center(
        child: Text(
          'Log Entry Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

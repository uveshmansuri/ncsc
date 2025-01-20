import 'package:flutter/material.dart';

class RecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records'),
      ),
      body: Center(
        child: Text(
          'Records Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

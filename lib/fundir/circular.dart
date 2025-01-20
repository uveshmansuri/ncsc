import 'package:flutter/material.dart';

class CircularsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circulars'),
      ),
      body: Center(
        child: Text(
          'Circulars Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

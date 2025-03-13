import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule")),
      body: Center(child: Text("Schedule Content Here", style: TextStyle(fontSize: 24))),
    );
  }
}

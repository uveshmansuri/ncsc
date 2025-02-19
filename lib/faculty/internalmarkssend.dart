import 'package:flutter/material.dart';

class InternalMarksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Internal Marks")),
      body: Center(child: Text("Internal Marks Content Here", style: TextStyle(fontSize: 24))),
    );
  }
}

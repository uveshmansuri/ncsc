import 'package:flutter/material.dart';

class computerlabdashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab Assistant Dashboard"),
      ),
      body: Center(
        child: Text(
          "Computer Lab Dashboard for Lab Assistant",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

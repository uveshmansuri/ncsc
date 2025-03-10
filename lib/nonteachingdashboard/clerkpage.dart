import 'package:flutter/material.dart';

class ClerkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clerk Page"),
      ),
      body: Center(
        child: Text(
          "Clerk Dashboard Page",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

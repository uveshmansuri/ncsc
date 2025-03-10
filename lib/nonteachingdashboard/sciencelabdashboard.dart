import 'package:flutter/material.dart';

class sciencelab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Science Lab Page"),
      ),
      body: Center(
        child: Text(
          "Science Lab Page for Science Lab Assistant",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

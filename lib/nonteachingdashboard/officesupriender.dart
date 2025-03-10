import 'package:flutter/material.dart';

class OfficeSuperintendentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Office Superintendent Page"),
      ),
      body: Center(
        child: Text(
          "Office Superintendent Dashboard",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

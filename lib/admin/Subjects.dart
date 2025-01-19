import 'package:NCSC/admin/Add_Subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Subjects extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subjects",
            style: TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.blue,
    ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0), // Center of the gradient
            radius: 1.0, // Spread of the gradient
            colors: [
              Color(0xffffffff),
              Color(0xFFE0F7FA), // Light blue (center)// Slightly darker blue (edges)
            ],
            stops: [0.3,1.0], // Defines the stops for the gradient
          ),
        ),
        child: Column(
          children: [

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Subject()));
        },
        child: Icon(Icons.add),
        tooltip: "Add Subject",
      ),
    );
  }
}
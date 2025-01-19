import 'package:flutter/material.dart';

class Add_Subject extends StatefulWidget{
  @override
  State<Add_Subject> createState() => _Add_SubjectState();
}

class _Add_SubjectState extends State<Add_Subject> {
  final sub_id=TextEditingController();
  final sub_name=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Subjects',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body:Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0,horizontal: 10),
          child: Column(
            children: [
              Form(
                  child: Column(
                    children: [
                      TextField(
                        controller: sub_id,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.numbers),
                          labelText: "Enter Subject Id",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                      ),
                      TextField(
                        controller: sub_name,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.numbers),
                          labelText: "Enter Subject Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
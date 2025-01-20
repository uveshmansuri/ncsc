import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class create_dept extends StatefulWidget {
  @override
  State<create_dept> createState() => _CreateDeptState();
}

class _CreateDeptState extends State<create_dept> {
  File? _imageFile;
  final _imgPicker = ImagePicker();
  String? imgEncode;

  // Controllers for input fields
  TextEditingController deptIdTextControl = TextEditingController();
  TextEditingController deptNameTextControl = TextEditingController();
  TextEditingController deptDescTextControl = TextEditingController();
  TextEditingController deptSemTextControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Departments',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0),
            radius: 1.0,
            colors: [Color(0xFFE0F7FA), Color(0xffffffff)],
            stops: [0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, size: 40, color: Colors.blue),
                    SizedBox(width: 30),
                    Text(
                      "Add Department",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                TextField(
                  controller: deptIdTextControl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.numbers),
                    labelText: "Enter Department ID",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: deptNameTextControl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.business_rounded),
                    labelText: "Enter Department Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: deptDescTextControl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.description),
                    labelText: "Enter Department Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: deptSemTextControl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.school),
                    labelText: "Enter Number of Semesters",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Select Image for Department'),
                    ),
                    if (imgEncode == null)
                      Text("No Image Selected")
                    else
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                        ),
                        child: Image.memory(
                          base64Decode(imgEncode!),
                          fit: BoxFit.scaleDown,
                        ),
                      )
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: addDept,
                  child: Text("Add Department"),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: BottomAppBar(
          color: Colors.blue,
          child: Text(
            '© NARMADA COLLEGE SCIENCE AND COMMERCE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imgPicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      String base64Image = base64Encode(await _imageFile!.readAsBytes());
      imgEncode = base64Image;
    }
  }

  void addDept() async {
    final dbRef = FirebaseDatabase.instance.ref();

    // Validate inputs
    if (deptIdTextControl.text.trim().isEmpty ||
        deptNameTextControl.text.trim().isEmpty ||
        deptDescTextControl.text.trim().isEmpty ||
        deptSemTextControl.text.trim().isEmpty ||
        imgEncode == null) {
      Fluttertoast.showToast(msg: "Please provide all details");
      return;
    }

    // Check if department ID already exists
    DataSnapshot snapshot = await dbRef
        .child("department")
        .child(deptIdTextControl.text.trim())
        .get();

    if (snapshot.exists) {
      Fluttertoast.showToast(msg: "Department ID already exists!");
      return;
    }

    // Add department data to Firebase
    dbRef
        .child("department")
        .child(deptIdTextControl.text.trim())
        .set({
      "department_id": deptIdTextControl.text.trim(),
      "department": deptNameTextControl.text.trim(),
      "dep_desc": deptDescTextControl.text.trim(),
      "dep_sem": deptSemTextControl.text.trim(),
      "img": imgEncode,
    })
        .then((_) {
      Fluttertoast.showToast(msg: "Department added successfully!");
      Navigator.pop(context, true);
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error: $error");
    });
  }
}

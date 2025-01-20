import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateSubjectPage extends StatefulWidget {
  @override
  _CreateSubjectPageState createState() => _CreateSubjectPageState();
}

class _CreateSubjectPageState extends State<CreateSubjectPage> {
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();

  String? _selectedDepartment;
  final List<String> _departments = ['BCA', 'B.Com', 'B.Sc', 'MBA'];

  final db_ref = FirebaseDatabase.instance.ref("subjects");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Subject',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0),
            radius: 1.0,
            colors: [
              Color(0xFFE0F7FA),
              Colors.white,
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTextField(
                        controller: _subjectCodeController,
                        label: 'Subject Code',
                        icon: Icons.code,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _subjectNameController,
                        label: 'Subject Name',
                        icon: Icons.book,
                      ),
                      SizedBox(height: 20),
                      _buildDropdown(),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _semesterController,
                        label: 'Semester',
                        icon: Icons.calendar_today,
                      ),
                      SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _addSubject,
                        child: Text(
                          'ADD SUBJECT',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      hint: Text('Select Department'),
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
        });
      },
      items: _departments.map((department) {
        return DropdownMenuItem(
          value: department,
          child: Text(department),
        );
      }).toList(),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.business, color: Colors.blue),
      ),
    );
  }

  void _addSubject() async {
    String subjectCode = _subjectCodeController.text.trim();
    String subjectName = _subjectNameController.text.trim();
    String? department = _selectedDepartment;
    String semester = _semesterController.text.trim();

    if (subjectCode.isEmpty || subjectName.isEmpty || department == null || semester.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Confirm before adding subject
    _showConfirmationDialog(subjectCode, subjectName, department, semester);
  }

  void _showConfirmationDialog(String subjectCode, String subjectName, String department, String semester) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_box),
              SizedBox(width: 10),
              Text("Subject Details"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Subject Code: $subjectCode"),
              Text("Subject Name: $subjectName"),
              Text("Department: $department"),
              Text("Semester: $semester"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Edit"),
            ),
            TextButton(
              onPressed: () {
                _addSubjectToDatabase(subjectCode, subjectName, department, semester);
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addSubjectToDatabase(String subjectCode, String subjectName, String department, String semester) async {
    try {
      final db_ref = FirebaseDatabase.instance.ref("subjects");

      // Check if subject already exists
      DataSnapshot snapshot = await db_ref.child(subjectCode).get();
      if (snapshot.exists) {
        Fluttertoast.showToast(msg: "Subject already exists");
        return;
      }

      // Add subject data to Firebase
      await db_ref.child(subjectCode).set({
        "subject_code": subjectCode,
        "subject_name": subjectName,
        "department": department,
        "semester": semester,
      });

      Fluttertoast.showToast(msg: "Subject Added Successfully");
      _clearFields();
    } catch (error) {
      Fluttertoast.showToast(msg: "Error: $error");
    }
  }

  void _clearFields() {
    _subjectCodeController.clear();
    _subjectNameController.clear();
    _semesterController.clear();
    setState(() {
      _selectedDepartment = null;
    });
  }
}

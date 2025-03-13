import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepartmentQueryPage extends StatefulWidget {
  @override
  _DepartmentQueryPageState createState() => _DepartmentQueryPageState();
}

class _DepartmentQueryPageState extends State<DepartmentQueryPage> {
  String? selectedDepartment;
  String? selectedSemester;
  String? userEmail;

  TextEditingController descriptionController = TextEditingController();
  Map<String, String> departmentMap = {}; // To store dept_id -> department name mapping

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  // Fetch the logged-in user's email
  void fetchCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email;
      fetchDepartments(); // Fetch department data first
    }
  }

  // Fetch Departments (Mapping dept_id to Department Name)
  void fetchDepartments() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("departments");
    DatabaseEvent event = await ref.once();

    Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        departmentMap = {
          for (var entry in data.entries) entry.value["department_id"]: entry.value["department"].toString()
        };
      });
      fetchStudentData(); // Fetch student data after getting department details
    }
  }

  // Fetch Student's Department & Semester based on their Email
  void fetchStudentData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Students");
    DatabaseEvent event = await ref.once();

    Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      for (var student in data.values) {
        if (student["email"] == userEmail) {
          setState(() {
            selectedSemester = "Semester ${student["sem"]}";
            selectedDepartment = departmentMap[student["dept_id"]];
          });
          break; // Exit loop once found
        }
      }
    }
  }

  // Submit Query to Firebase
  void submitQuery() {
    if (selectedDepartment == null || selectedSemester == null || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref("queries").push();
    ref.set({
      "department": selectedDepartment,
      "semester": selectedSemester,
      "description": descriptionController.text,
      "timestamp": DateTime.now().toString(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Query submitted successfully!")),
      );
      descriptionController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit query")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Department Query'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Department", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              initialValue: selectedDepartment,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            Text("Semester", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              initialValue: selectedSemester,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            Text("Enter Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter your query...",
              ),
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: submitQuery,
                child: Text("Submit Query"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

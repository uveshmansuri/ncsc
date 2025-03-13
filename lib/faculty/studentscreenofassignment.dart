import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentListScreen extends StatefulWidget {
  final String department;
  final String semester;
  final String assignmentTitle;
  final String facultyName;
  final String subjectId;

  StudentListScreen({
    required this.department,
    required this.semester,
    required this.assignmentTitle,
    required this.facultyName,
    required this.subjectId,
  });

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final databaseRef = FirebaseDatabase.instance.ref("Students");
  List<Map<String, dynamic>> students = [];
  Map<String, bool> selectedStudents = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      DatabaseReference ref = databaseRef.child(widget.department).child(widget.semester);
      DataSnapshot snapshot = (await ref.get());

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> studentsData = Map<String, dynamic>.from(snapshot.value as Map);
        List<Map<String, dynamic>> fetchedStudents = [];

        studentsData.forEach((key, value) {
          if (value is Map) {
            fetchedStudents.add({
              "stud_id": key,
              "name": value["name"],
              "email": value["email"],
            });
            selectedStudents[key] = false; // Initialize as unchecked
          }
        });

        setState(() {
          students = fetchedStudents;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching students: $e")),
      );
    }
  }

  Future<void> saveSelectedStudents() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref("Assignments")
          .child(widget.department)
          .child(widget.semester)
          .child(widget.subjectId)
          .child(widget.facultyName)
          .child(widget.assignmentTitle)
          .child("completed_students");

      Map<String, bool> selectedData = {};
      selectedStudents.forEach((key, value) {
        if (value) {
          selectedData[key] = true;
        }
      });

      await ref.set(selectedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected students saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving students: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Students")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : students.isEmpty
          ? Center(child: Text("No Students Found"))
          : ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          String studentId = students[index]["stud_id"];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(students[index]["name"] ?? "Unknown"),
              subtitle: Text(students[index]["email"] ?? "No Email"),
              trailing: Checkbox(
                value: selectedStudents[studentId] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    selectedStudents[studentId] = value ?? false;
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveSelectedStudents,
        child: Icon(Icons.save),
        tooltip: "Save Selected Students",
      ),
    );
  }
}

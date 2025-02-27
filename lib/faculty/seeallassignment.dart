import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'studentscreenofassignment.dart';

class AssignmentListScreen extends StatefulWidget {
  final String department;
  final String semester;
  final List<Map<String, String>> subject;

  AssignmentListScreen({
    required this.department,
    required this.semester,
    required this.subject,
  });

  @override
  _AssignmentListScreenState createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final databaseRef = FirebaseDatabase.instance.ref("Assignments");
  List<Map<String, dynamic>> assignments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      DatabaseReference ref = databaseRef.child(widget.department).child(widget.semester);
      DataSnapshot snapshot = (await ref.get());

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> subjectsData = Map<String, dynamic>.from(snapshot.value as Map);
        List<Map<String, dynamic>> fetchedAssignments = [];

        subjectsData.forEach((subjectId, facultyData) {
          if (facultyData is Map) {
            facultyData.forEach((facultyName, assignmentsData) {
              if (assignmentsData is Map) {
                assignmentsData.forEach((title, assignmentDetails) {
                  if (assignmentDetails is Map) {
                    fetchedAssignments.add({
                      "title": title,
                      "lastDate": assignmentDetails["lastDate"],
                      "subject": widget.subject.firstWhere(
                            (subj) => subj['id'] == subjectId,
                        orElse: () => {"name": "Unknown"},
                      )["name"],
                      "facultyName": facultyName,
                      "subjectId": subjectId,
                    });
                  }
                });
              }
            });
          }
        });

        setState(() {
          assignments = fetchedAssignments;
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
        SnackBar(content: Text("Error fetching assignments: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assignments")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : assignments.isEmpty
          ? Center(child: Text("No Assignments Found"))
          : ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(assignments[index]["title"] ?? "No Title"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subject: ${assignments[index]["subject"]}"),
                  Text("Last Date: ${assignments[index]["lastDate"]}"),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentListScreen(
                      department: widget.department,
                      semester: widget.semester,
                      assignmentTitle: assignments[index]["title"],
                      facultyName: assignments[index]["facultyName"],
                      subjectId: assignments[index]["subjectId"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

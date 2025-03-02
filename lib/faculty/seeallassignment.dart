import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'addassignment.dart';
import 'assignmentpagelist.dart';

class AssignmentPage extends StatefulWidget {
  final String dept, sem, faculty, subjectName;

  AssignmentPage({
    required this.dept,
    required this.sem,
    required this.faculty,
    required this.subjectName,
  });

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  List<Map<String, dynamic>> assignments = [];
  final databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      final assignmentRef = databaseRef
          .child('Assignments')
          .child(widget.dept)
          .child(widget.sem)
          .child(widget.subjectName)
          .child(widget.faculty);

      DatabaseEvent event = await assignmentRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> assignmentsData = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          assignments = assignmentsData.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value);
            return {
              'title': entry.key,
              'subject': data['subjectName'] ?? widget.subjectName,
              'lastDate': data['lastDate'] ?? 'No Date',
              'fileType': data['fileType'] ?? 'Text',
            };
          }).toList();
        });
      } else {
        setState(() {
          assignments = [];
        });
      }
    } catch (e) {
      setState(() {
        assignments = [];
      });
      print("Error fetching assignments: $e");
    }
  }

  void deleteAssignment(String assignmentKey) async {
    try {
      await databaseRef
          .child('Assignments')
          .child(widget.dept)
          .child(widget.sem)
          .child(widget.subjectName)
          .child(widget.faculty)
          .child(assignmentKey)
          .remove();

      fetchAssignments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assignment deleted successfully!")),
      );
    } catch (e) {
      print("Error deleting assignment: $e");
    }
  }

  void showDeleteDialog(String assignmentKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Assignment"),
        content: Text("Are you sure you want to delete this assignment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteAssignment(assignmentKey);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assignments")),
      body: assignments.isEmpty
          ? Center(child: Text("No assignments uploaded yet."))
          : ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, i) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(assignments[i]['title']),
              subtitle: Text(
                  "Subject: ${assignments[i]['subject']}\nDue: ${assignments[i]['lastDate']}"),
              trailing: Icon(
                assignments[i]['fileType'] == 'pdf'
                    ? Icons.picture_as_pdf
                    : assignments[i]['fileType'] == 'image'
                    ? Icons.image
                    : Icons.text_snippet,
                color: assignments[i]['fileType'] == 'pdf' ? Colors.red : Colors.blue,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentDetailPage(
                      dept: widget.dept,
                      sem: widget.sem,
                      faculty: widget.faculty,
                      subjectName: widget.subjectName,
                      assignmentKey: assignments[i]['title'],
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDeleteDialog(assignments[i]['title']);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadAssignment(
              facultyId: widget.faculty,
              department: widget.dept,
              semester: widget.sem,
              subjectId: widget.subjectName,
              subjectName: widget.subjectName,
            ),
          ),
        ).then((_) => fetchAssignments()),
        child: Icon(Icons.add),
      ),
    );
  }
}

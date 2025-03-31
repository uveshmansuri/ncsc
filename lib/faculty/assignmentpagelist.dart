import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AssignmentDetailPage extends StatefulWidget {
  final String dept, sem, faculty, subjectName, assignmentKey;

  AssignmentDetailPage({
    required this.dept,
    required this.sem,
    required this.faculty,
    required this.subjectName,
    required this.assignmentKey,
  });

  @override
  _AssignmentDetailPageState createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  final databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> students = [];
  Map<String, bool> selectedStudents = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }
  Future<void> fetchStudents() async {
    try {
      final studentRef = databaseRef.child('Students');
      DatabaseEvent event = await studentRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> studentData = Map<String, dynamic>.from(
            snapshot.value as Map);

        List<Map<String, dynamic>> studentList = studentData.entries
            .map((entry) => Map<String, dynamic>.from(entry.value))
            .where((student) =>
        student['dept'] == widget.dept && student['sem'] == widget.sem)
            .toList();

        setState(() {
          students = studentList;
          selectedStudents =
          {for (var student in students) student['stud_id']: false};
        });

        fetchExistingSubmissions();
      } else {
        setState(() {
          students = [];
          selectedStudents = {};
        });
      }
    } catch (e) {
      print("❌ Error fetching students: $e");
      setState(() {
        students = [];
        selectedStudents = {};
      });
    }
  }
  Future<void> fetchExistingSubmissions() async {
    try {
      final submissionRef = databaseRef
          .child('Assignments')
          .child(widget.dept)
          .child(widget.sem)
          .child(widget.subjectName)
          .child(widget.faculty)
          .child(widget.assignmentKey)
          .child('studentSubmitted');

      DatabaseEvent event = await submissionRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> submissionData = Map<String, dynamic>.from(
            snapshot.value as Map);

        setState(() {
          for (var student in students) {
            String studentId = student['stud_id'];
            if (submissionData.containsKey(studentId)) {
              selectedStudents[studentId] =
              submissionData[studentId];
            }
          }
        });
      }
    } catch (e) {
      print("❌ Error fetching submission status: $e");
    }
  }
  Future<void> saveStudentSubmission() async {
    try {
      final assignmentRef = databaseRef
          .child('Assignments')
          .child(widget.dept)
          .child(widget.sem)
          .child(widget.subjectName)
          .child(widget.faculty)
          .child(widget.assignmentKey)
          .child('studentSubmitted');
      Map<String, dynamic> studentData = {
        for (var entry in selectedStudents.entries) if (entry.value) entry
            .key: true
      };

      await assignmentRef.set(studentData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Student submissions saved successfully!")),
      );
    } catch (e) {
      print("❌ Error saving student submissions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assignment Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📋 Students List",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: students.isEmpty
                  ? Center(child: Text(
                  "No students found for this department and semester."))
                  : ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  String studentName = students[index]['name'] ??
                      "Unknown Name";
                  String studentId = students[index]['stud_id'];

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(studentName),
                      subtitle: Text("ID: $studentId"),
                      trailing: Checkbox(
                        value: selectedStudents[studentId] ?? false,
                        onChanged: (bool? newValue) {
                          setState(() {
                            selectedStudents[studentId] = newValue ?? false;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ Centering in Row
              children: [
                ElevatedButton(
                  onPressed: saveStudentSubmission,
                  child: Text("Save"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

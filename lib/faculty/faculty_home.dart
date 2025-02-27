import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:NCSC/faculty/addassignment.dart';
import 'Subject_List_Faculty.dart';
import 'attendancetake.dart';
import 'internalmarkssend.dart';
import 'package:NCSC/faculty/schedule.dart';

class HomePage extends StatefulWidget {
  final String fid;
  HomePage(this.fid);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _base64Image;
  String? facultyName;
  bool isLoading = true;
  Map<String, Map<String, List<Map<String, String>>>> facultySubjects = {};

  @override
  void initState() {
    super.initState();
    fetchFacultyData();
  }

  void fetchFacultyData() {
    DatabaseReference facultyRef = FirebaseDatabase.instance.ref("Staff/faculty/${widget.fid}");
    DatabaseReference subjectsRef = FirebaseDatabase.instance.ref("Subjects");

    facultyRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _base64Image = data["image"];
          facultyName = data["name"];
        });
      }
    });

    // Fetch subjects assigned to this faculty
    subjectsRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        Map<String, Map<String, List<Map<String, String>>>> fetchedSubjects = {};

        data.forEach((key, value) {
          if (value is Map && value["faculty"] == widget.fid) {
            String department = value["dept"] ?? "Unknown Department";
            String semester = value["sem"] ?? "Unknown Semester";

            if (!fetchedSubjects.containsKey(department)) {
              fetchedSubjects[department] = {};
            }
            if (!fetchedSubjects[department]!.containsKey(semester)) {
              fetchedSubjects[department]![semester] = [];
            }

            fetchedSubjects[department]![semester]!.add({
              "id": value["id"],
              "name": value["name"],
            });
          }
        });

        setState(() {
          facultySubjects = fetchedSubjects;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: _base64Image != null
                  ? MemoryImage(base64Decode(_base64Image!))
                  : AssetImage("assets/images/faculty_icon.png") as ImageProvider,
              radius: 18,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildCard(context, "Schedule", Icons.schedule, SchedulePage()),
          buildCard(context, "Attendance", Icons.check_circle, faculty_sub_lst(widget.fid, 0)),
          buildCard(context, "Internal Marks", Icons.score, faculty_sub_lst(widget.fid, 1)),
          buildAssignmentCard(context),
        ],
      ),
    );
  }

  Widget buildAssignmentCard(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.assignment, size: 30),
        title: Text("Assignment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          if (facultySubjects.isNotEmpty) {
            showDepartmentSelectionDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No subjects available.")));
          }
        },
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
      ),
    );
  }

  void showDepartmentSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Department & Semester"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: facultySubjects.entries.map((deptEntry) {
              return ExpansionTile(
                title: Text(deptEntry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                children: deptEntry.value.entries.map((semEntry) {
                  return ListTile(
                    title: Text("Semester ${semEntry.key}"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadAssignment(
                            facultyName: facultyName!,
                            department: deptEntry.key,
                            semester: semEntry.key,
                            subjects: semEntry.value,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

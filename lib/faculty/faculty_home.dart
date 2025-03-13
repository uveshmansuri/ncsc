import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Subject_List_Faculty.dart';
import 'package:NCSC/faculty/schedule.dart';

class HomePage extends StatefulWidget {
  final String fid;
  HomePage(this.fid);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _base64Image;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacultyData();
  }

  void fetchFacultyData() {
    DatabaseReference facultyRef = FirebaseDatabase.instance.ref("Staff/faculty/${widget.fid}");

    facultyRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _base64Image = data["image"];
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
          buildCard(context, "Assignment", Icons.menu_book, faculty_sub_lst(widget.fid, 2)),
          buildCard(context, "Test", Icons.assignment, faculty_sub_lst(widget.fid, 3)),
        ],
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
}

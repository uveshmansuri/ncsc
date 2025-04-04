import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Subject_List_Faculty.dart';
import 'package:NCSC/faculty/schedule.dart';
import 'hodquery.dart';

class HomePage extends StatefulWidget {
  final String fid;
  HomePage(this.fid);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _base64Image,post,dept;
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
          post=data['post'];
          dept=data['department'];
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
          ?
      Center(child: CircularProgressIndicator())
          :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if(post=="HOD")
                build_Hod_widgets(),
              buildCard(context, "Time Table", Icons.schedule,SchedulePage(fid: widget.fid, dept: dept, ishod: post=="HOD")),
              buildCard(context, "Attendance", Icons.check_circle, faculty_sub_lst(widget.fid, 0,false,dept)),
              buildCard(context, "Internal Marks", Icons.bookmark_add_sharp, faculty_sub_lst(widget.fid, 1,false,dept)),
              buildCard(context, "Assignment", Icons.menu_book, faculty_sub_lst(widget.fid, 2,false,dept)),
              buildCard(context, "Test", Icons.assignment, faculty_sub_lst(widget.fid, 3,false,dept)),
            ],
          ),
        ),
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

  Widget build_Hod_widgets(){
    return Column(
      children: [
        buildCard(context, "Department Attendance Report", Icons.assignment_turned_in, faculty_sub_lst(widget.fid, 0,true,dept)),
        buildCard(context, "Department Internal Marks Report", Icons.grade, faculty_sub_lst(widget.fid, 1,true,dept)),
        buildCard(context, "Department Assignment Report", Icons.assignment_ind_outlined, faculty_sub_lst(widget.fid, 2,true,dept)),
        buildCard(context, "Students Query", Icons.question_answer, HodDepartmentQuery(dept: dept!)),
      ],
    );
  }
}
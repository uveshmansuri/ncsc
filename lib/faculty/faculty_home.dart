import 'package:NCSC/faculty/addassignment.dart';
import 'package:NCSC/faculty/schedule.dart';
import 'package:NCSC/faculty/timetable.dart';
import 'package:flutter/material.dart';
import 'attendancetake.dart';
import 'internalmarkssend.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpg"),
              radius: 18,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildCard(context, "Schedule", Icons.schedule, SchedulePage()),
          buildCard(context, "Attendance", Icons.check_circle, AttendancePage()),
          buildCard(context, "TimeTable", Icons.calendar_today, TimeTablePage()),
          buildCard(context, "Internal Marks", Icons.score, InternalMarksPage()),
          buildCard(context, "Assignment", Icons.assignment, AssignmentPage()),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
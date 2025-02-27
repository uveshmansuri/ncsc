import 'package:flutter/material.dart';
import 'package:NCSC/nonteachingstaff/labattendance.dart';
import 'package:NCSC/nonteachingstaff/leavereq.dart';
import 'package:NCSC/nonteachingstaff/newsforall.dart';
import 'package:NCSC/nonteachingstaff/queryfile.dart';
import 'package:NCSC/nonteachingstaff/recordofpc.dart';

class NonTeachingDashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {'title': 'Attendance', 'icon': Icons.check_circle, 'route': Attendancelab()},
    {'title': 'News', 'icon': Icons.article, 'route': NewsScreen()},
    {'title': 'Leave Request', 'icon': Icons.event_note, 'route': LeaveRequestScreen()},
    {'title': 'Query', 'icon': Icons.help_outline, 'route': QueryScreen()},
    {'title': 'Record', 'icon': Icons.folder, 'route': RecordScreen()},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => items[index]['route']),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  shadowColor: Colors.grey,
                  child: ListTile(
                    leading: Icon(items[index]['icon'], size: 40, color: Colors.blueAccent),
                    title: Text(
                      items[index]['title'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

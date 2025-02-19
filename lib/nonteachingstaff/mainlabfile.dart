import 'package:NCSC/nonteachingstaff/labattendance.dart';
import 'package:NCSC/nonteachingstaff/leavereq.dart';
import 'package:NCSC/nonteachingstaff/newsforall.dart';
import 'package:NCSC/nonteachingstaff/queryfile.dart';
import 'package:NCSC/nonteachingstaff/recordofpc.dart';
import 'package:flutter/material.dart';

class nonteachingDashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {'title': 'Attendance', 'route': Attendancelab()},
    {'title': 'News', 'route': NewsScreen()},
    {'title': 'Leave Request', 'route': LeaveRequestScreen()},
    {'title': 'Query', 'route': QueryScreen()},
    {'title': 'Record', 'route': RecordScreen()},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
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
                child: Center(
                  child: Text(
                    items[index]['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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



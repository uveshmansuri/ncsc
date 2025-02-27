import 'package:NCSC/student/departmentquery.dart';
import 'package:NCSC/student/labquery.dart';
import 'package:NCSC/student/sciencelab.dart';
import 'package:flutter/material.dart';


class QueryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query Section'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildQueryCard(context, 'Department Query', Icons.business, DepartmentQueryPage()),
            SizedBox(height: 16),
            _buildQueryCard(context, 'Lab Query', Icons.computer, LabQueryPage()),
            SizedBox(height: 16),
            _buildQueryCard(context, 'Science Lab Query', Icons.science, ScienceLabQueryPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

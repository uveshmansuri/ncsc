import 'package:NCSC/student/departmentquery.dart';
import 'package:NCSC/student/labquery.dart';
import 'package:NCSC/student/sciencelab.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QueryPage extends StatefulWidget {
  final String stud_id;
  QueryPage({required this.stud_id});

  @override
  _QueryPageState createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  String department = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDepartment();
  }

  void fetchDepartment() async {
    try {
      var db = await FirebaseDatabase.instance
          .ref("Students/${widget.stud_id}/dept")
          .get();
      setState(() {
        department = db.value.toString();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching department: $e");
      setState(() {
        department = "Unknown";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Query Section'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildQueryCard(context, 'Department Query', Icons.business, DepartmentQueryPage()),
            if (department == 'BCA') ...[
              SizedBox(height: 16),
              _buildQueryCard(context, 'Lab Query', Icons.computer, LabQueryPage(stud_id: widget.stud_id,dept: "BCA",)),
            ] else if (department == 'BSC') ...[
              SizedBox(height: 16),
              _buildQueryCard(context, 'Science Lab Query', Icons.science, ScienceLabQueryPage()),
            ],
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

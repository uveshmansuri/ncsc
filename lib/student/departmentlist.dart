import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DepartmentList extends StatefulWidget {
  @override
  State<DepartmentList> createState() => _DepartmentListState();
}

class _DepartmentListState extends State<DepartmentList> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("department");
  List<Map<String, String>> departments = [];
  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Departments", style: TextStyle(fontSize: 25, color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: departments.isEmpty
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeWidth: 5.0,
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: dept['img']!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(dept['img']!),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
              title: Text(
                dept['department']!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            '© NARMADA COLLEGE SCIENCE AND COMMERCE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// Fetches department data from Firebase
  void fetchDepartments() async {
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      departments.clear();
      snapshot.children.forEach((sp) {
        String department = sp.child("department").value.toString();
        String img = sp.child("img").value != null ? sp.child("img").value.toString() : "";
        departments.add({"department": department, "img": img});
      });
      setState(() {});
    }
  }
}

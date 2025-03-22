import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'facultywholeinfo.dart';

class FacultyListPage extends StatefulWidget {
  final String departmentName;

  FacultyListPage({required this.departmentName});

  @override
  State<FacultyListPage> createState() => _FacultyListPageState();
}

class _FacultyListPageState extends State<FacultyListPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Staff/faculty");
  List<Map<String, String>> facultyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFaculty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.departmentName} Faculty", style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 5.0))
          : facultyList.isEmpty
          ? Center(child: Text("No faculty found for this department", style: TextStyle(fontSize: 18)))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: facultyList.length,
        itemBuilder: (context, index) {
          final faculty = facultyList[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: ClipOval(
                child: faculty['image'] != null && faculty['image']!.isNotEmpty
                    ? Image.memory(
                  base64Decode(faculty['image']!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
                ),
              ),
              title: Text(
                faculty['name']!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultyDetailPage(facultyId: faculty['id']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  void fetchFaculty() async {
    try {
      final snapshot = await dbRef.get();
      print("Fetching faculty data from Firebase...");

      if (snapshot.exists) {
        facultyList.clear();

        for (var facultySnapshot in snapshot.children) {
          String? facultyId = facultySnapshot.key;
          String? department = facultySnapshot.child("department").value?.toString();
          String? name = facultySnapshot.child("name").value?.toString();
          String? experience = facultySnapshot.child("experience").value?.toString();
          String? image = facultySnapshot.child("image").value?.toString();

          print("Checking faculty: $facultyId, Department: $department");

          if (department != null &&
              department.trim().toLowerCase() == widget.departmentName.trim().toLowerCase()) {
            facultyList.add({
              "id": facultyId ?? "",
              "name": name ?? "Unknown",
              "experience": experience ?? "0",
              "image": image ?? "",
            });
          }
        }
      } else {
        print("No faculty data found in Firebase!");
      }
    } catch (e) {
      print("Error fetching faculty data: $e");
    }

    setState(() {
      isLoading = false;
    });
  }
}

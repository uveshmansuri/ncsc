import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FacultyDetailPage extends StatefulWidget {
  final String facultyId;

  FacultyDetailPage({required this.facultyId});

  @override
  _FacultyDetailPageState createState() => _FacultyDetailPageState();
}

class _FacultyDetailPageState extends State<FacultyDetailPage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("Staff/faculty");
  Map<String, String> facultyData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacultyDetails();
  }

  /// Fetch faculty details from Firebase
  void fetchFacultyDetails() async {
    try {
      final snapshot = await dbRef.child(widget.facultyId).get();

      if (snapshot.exists) {
        facultyData = {
          "name": snapshot.child("name").value?.toString() ?? "Unknown",
          "email": snapshot.child("email").value?.toString() ?? "N/A",
          "phone": snapshot.child("phone").value?.toString() ?? "N/A",
          "department": snapshot.child("department").value?.toString() ?? "N/A",
          "experience": snapshot.child("experience").value?.toString() ?? "0",
          "post": snapshot.child("post").value?.toString() ?? "N/A",
          "qualification": snapshot.child("qualification").value?.toString() ?? "N/A",
          "address": snapshot.child("address").value?.toString() ?? "N/A",
          "image": snapshot.child("image").value?.toString() ?? "",
        };
      }
    } catch (e) {
      print("Error fetching faculty details: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background for contrast
      appBar: AppBar(
        title: Text("Faculty Details", style: TextStyle(fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 5.0))
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Faculty Image with Shadow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  backgroundImage: facultyData['image']!.isNotEmpty
                      ? MemoryImage(base64Decode(facultyData['image']!))
                      : null,
                  child: facultyData['image']!.isEmpty
                      ? Icon(Icons.person, size: 65, color: Colors.grey[600])
                      : null,
                ),
              ),
              SizedBox(height: 20),

              /// Faculty Details in Cards
              buildInfoCard("Name", facultyData['name']!),
              buildInfoCard("Email", facultyData['email']!),
              buildInfoCard("Phone", facultyData['phone']!),
              buildInfoCard("Department", facultyData['department']!),
              buildInfoCard("Experience", "${facultyData['experience']} years"),
              buildInfoCard("Post", facultyData['post']!),
              buildInfoCard("Qualification", facultyData['qualification']!),
              buildInfoCard("Address", facultyData['address']!),
            ],
          ),
        ),
      ),
    );
  }

  /// Function to build Card-based UI for Faculty Details
  Widget buildInfoCard(String label, String value) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

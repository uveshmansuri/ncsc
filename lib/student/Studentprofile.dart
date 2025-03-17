import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentProfilePage extends StatefulWidget {
  final String stud_id;
  const StudentProfilePage({required this.stud_id, Key? key}) : super(key: key);

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late String studName;
  late String studDept;
  late String studEmail;
  late String studSem;
  late String studUrl;
  bool isLoading = true;
  bool imageError = false;

  @override
  void initState() {
    super.initState();
    fetchStudentProfile();
  }

  Future<void> fetchStudentProfile() async {
    try {
      DatabaseReference studentRef =
      FirebaseDatabase.instance.ref("Students").child(widget.stud_id);
      DataSnapshot snapshot = await studentRef.get();

      if (snapshot.exists) {
        setState(() {
          studName = snapshot.child("name").value.toString();
          studDept = snapshot.child("dept").value.toString();
          studEmail = snapshot.child("email").value.toString();
          studSem = snapshot.child("sem").value.toString();
          studUrl = snapshot.child("url").value.toString();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching student profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: imageError || studUrl.isEmpty
                    ? const AssetImage('assets/images/student_profile.png')
                as ImageProvider
                    : NetworkImage(studUrl),
                onBackgroundImageError: (_, __) {
                  setState(() {
                    imageError = true;
                  });
                },
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          studName,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: Text(
                          studDept,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          'Semester: $studSem',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: Text(
                          studEmail,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

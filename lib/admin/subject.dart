import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'create_subject.dart'; // Import your subject creation page

class SubjectPage extends StatefulWidget {
  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final dbRef = FirebaseDatabase.instance.ref("Subjects");
  final List<SubjectModel> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0),
            radius: 1.0,
            colors: [Color(0xffffffff), Color(0xFFE0F7FA)],
            stops: [0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Hero(
              tag: "subject",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    child: Image.asset("assets/images/faculty_icon.png", height: 60, width: 60),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Subjects',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _subjects.isEmpty
                  ? Center(
                child: Container(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    backgroundColor: Colors.grey,
                    strokeWidth: 5.0,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  return Card(
                    elevation: 10,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        leading: Icon(Icons.book, size: 50, color: Colors.blue),
                        title: Text(subject.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                        subtitle: Text('Code: ${subject.code}'),
                        trailing: Text('Semester: ${subject.semester}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool res = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => CreateSubjectPage()));
          if (res) {
            _subjects.clear();
            _fetchSubjects();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: BottomAppBar(
          color: Colors.blue,
          child: Text(
            '© NARMADA COLLEGE SCIENCE AND COMMERCE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _fetchSubjects() async {
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      for (DataSnapshot sp in snapshot.children) {
        var code = sp.child("code").value.toString();
        var name = sp.child("name").value.toString();
        var semester = sp.child("semester").value.toString();
        _subjects.add(SubjectModel(code, name, semester));
      }
    }
    setState(() {});
  }
}

class SubjectModel {
  String code, name, semester;
  SubjectModel(this.code, this.name, this.semester);
}

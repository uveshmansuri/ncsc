import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Createschedulepage extends StatefulWidget {
  final String department;

  Createschedulepage({required this.department});

  @override
  State<Createschedulepage> createState() => _CreateschedulepageState();
}

class _CreateschedulepageState extends State<Createschedulepage> {
  List<Map<String, String>> subjectList = [];
  Map<String, TextEditingController> controllers = {};
  bool isLoading = true;
  Map<String, String> facultyMap = {};

  @override
  void initState() {
    super.initState();
    fetchFacultyNames();
  }
  void fetchFacultyNames() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("faculty");
    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    Map<String, String> tempFacultyMap = {};

    for (DataSnapshot sp in snapshot.children) {
      String fid = sp.key.toString(); // Ensure this matches "ass_faculties"
      String name = sp.child("name").value.toString();

      tempFacultyMap[fid] = name; // Store faculty name using ID
    }

    setState(() {
      facultyMap = tempFacultyMap;
    });

    fetchSubjects();
  }
  void fetchSubjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Subjects");
    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    List<Map<String, String>> tempList = [];

    for (DataSnapshot sp in snapshot.children) {
      if (sp.child("dept").value.toString() == widget.department) {
        String subjectName = sp.child("name").value.toString();
        String semester = sp.child("sem").value.toString();
        String facultyId = sp.child("ass_faculties").value.toString().trim();

        tempList.add({
          "subject": subjectName,
          "semester": semester,
          "facultyId": facultyId,
          "faculty": facultyMap.containsKey(facultyId) ? facultyMap[facultyId]! : "Unknown", // Assign correct name
        });

        controllers[subjectName] = TextEditingController();
      }
    }

    setState(() {
      subjectList = tempList;
      isLoading = false;
    });
  }


  /// Get Entered Values
  void printEnteredValues() {
    subjectList.forEach((subject) {
      String subjectName = subject["subject"]!;
      String enteredValue = controllers[subjectName]!.text;
      print("Subject: $subjectName, Entered Number: $enteredValue");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subjects for ${widget.department}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : subjectList.isEmpty
          ? Center(child: Text("No subjects available"))
          : ListView.builder(
        itemCount: subjectList.length,
        itemBuilder: (context, index) {
          var subject = subjectList[index];
          String subjectName = subject["subject"]!;

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Subject: ${subject["subject"]}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Semester: ${subject["semester"]}"),
                  Text("Faculty: ${subject["faculty"]}"),
                  SizedBox(height: 10),
                  TextField(
                    controller: controllers[subjectName],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Enter Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: printEnteredValues,
        child: Icon(Icons.check),
      ),
    );
  }
}

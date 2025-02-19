import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class AssignmentPage extends StatefulWidget {
  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  final TextEditingController _questionController = TextEditingController();
  String? selectedSubject;
  String? selectedSemester;
  File? selectedPdf;
  bool isUploading = false;
  List<Map<String, String>> subjectsList = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Subjects");
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      List<Map<String, String>> tempList = [];
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        tempList.add({
          "name": value["name"], // Subject name
          "sem": value["sem"],   // Semester
        });
      });

      setState(() {
        subjectsList = tempList;
      });
    }
  }

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedPdf = File(result.files.single.path!);
        _questionController.clear(); // Clear text field when PDF is selected
      });
    }
  }

  Future<void> uploadAssignment() async {
    if (selectedSubject == null || selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a subject and semester")),
      );
      return;
    }

    if (_questionController.text.isEmpty && selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please either write questions or upload a PDF")),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String pdfUrl = "";

      if (selectedPdf != null) {
        String fileName = "assignments/${DateTime.now().millisecondsSinceEpoch}.pdf";
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(selectedPdf!);
        TaskSnapshot taskSnapshot = await uploadTask;
        pdfUrl = await taskSnapshot.ref.getDownloadURL();
      }
      DatabaseReference dbRef = FirebaseDatabase.instance.ref("assignments").push();
      await dbRef.set({
        "subject": selectedSubject,
        "semester": selectedSemester,
        "questions": _questionController.text.isNotEmpty ? _questionController.text : null,
        "pdfUrl": pdfUrl.isNotEmpty ? pdfUrl : null,
        "timestamp": DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assignment uploaded successfully!")),
      );
      setState(() {
        selectedSubject = null;
        selectedSemester = null;
        _questionController.clear();
        selectedPdf = null;
        isUploading = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading assignment: $e")),
      );
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Assignment")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Subject", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedSubject,
              hint: Text("Choose Subject"),
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                  selectedSemester = subjectsList.firstWhere((element) => element["name"] == value)?["sem"];
                });
              },
              items: subjectsList.map((subject) {
                return DropdownMenuItem(value: subject["name"], child: Text(subject["name"]!));
              }).toList(),
            ),

            SizedBox(height: 10),
            Text("Semester", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              selectedSemester ?? "Select a subject first",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            SizedBox(height: 10),
            Text("Enter Questions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _questionController,
              maxLines: 5,
              enabled: selectedPdf == null, // Disable if PDF is selected
              decoration: InputDecoration(
                hintText: "Write assignment questions here...",
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  setState(() {
                    selectedPdf = null; // Remove PDF if user types text
                  });
                }
              },
            ),

            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _questionController.text.isEmpty ? pickPdfFile : null,
              icon: Icon(Icons.upload_file),
              label: Text("Upload PDF"),
            ),
            selectedPdf != null
                ? Text("Selected PDF: ${selectedPdf!.path.split('/').last}")
                : Text("No PDF selected"),

            SizedBox(height: 20),
            isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: uploadAssignment,
              child: Text("Submit Assignment"),
            ),
          ],
        ),
      ),
    );
  }
}

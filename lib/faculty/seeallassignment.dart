import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'addassignment.dart';
import 'assignmentpagelist.dart';

class AssignmentPage extends StatefulWidget {
  final String dept, sem, faculty, subjectName;
  final bool ishod;

  AssignmentPage({
    required this.dept,
    required this.sem,
    required this.faculty,
    required this.subjectName,
    this.ishod = false,
  });

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  List<Map<String, dynamic>> assignments = [];
  final databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      DatabaseReference assignmentRef;

      if (widget.ishod) {
        assignmentRef = databaseRef
            .child('Assignments')
            .child(widget.dept)
            .child(widget.sem)
            .child(widget.subjectName);
      } else {
        assignmentRef = databaseRef
            .child('Assignments')
            .child(widget.dept)
            .child(widget.sem)
            .child(widget.subjectName)
            .child(widget.faculty);
      }

      DatabaseEvent event = await assignmentRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value is Map) {
        List<Map<String, dynamic>> tempAssignments = [];

        Map<String, dynamic> assignmentData = Map<String, dynamic>.from(snapshot.value as Map);

        if (widget.ishod) {

          assignmentData.forEach((facultyName, facultyAssignments) {
            if (facultyAssignments is Map) {
              facultyAssignments.forEach((key, value) {
                final data = Map<String, dynamic>.from(value);
                tempAssignments.add({
                  'title': key,
                  'subject': data['subjectName'] ?? widget.subjectName,
                  'lastDate': data['lastDate'] ?? 'No Date',
                  'fileType': data['fileType'] ?? 'Text',
                  'content': data['content'],
                  'faculty': facultyName,
                });
              });
            }
          });
        } else {

          assignmentData.forEach((key, value) {
            final data = Map<String, dynamic>.from(value);
            tempAssignments.add({
              'title': key,
              'subject': data['subjectName'] ?? widget.subjectName,
              'lastDate': data['lastDate'] ?? 'No Date',
              'fileType': data['fileType'] ?? 'Text',
              'content': data['content'],
            });
          });
        }

        setState(() {
          assignments = tempAssignments;
        });
      } else {
        setState(() {
          assignments = [];
        });
      }
    } catch (e) {
      setState(() {
        assignments = [];
      });
      print("Error fetching assignments: $e");
    }
  }



  void deleteAssignment(String assignmentKey) async {
    try {
      await databaseRef
          .child('Assignments')
          .child(widget.dept)
          .child(widget.sem)
          .child(widget.subjectName)
          .child(widget.faculty)
          .child(assignmentKey)
          .remove();

      fetchAssignments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assignment deleted successfully!")),
      );
    } catch (e) {
      print("Error deleting assignment: $e");
    }
  }

  void showDeleteDialog(String assignmentKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Assignment"),
        content: Text("Are you sure you want to delete this assignment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteAssignment(assignmentKey);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assignments")),
      body: assignments.isEmpty
          ? Center(child: Text("No assignments uploaded yet."))
          : ListView.builder(
        itemCount: assignments.length,
        itemBuilder: (context, i) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(assignments[i]['title']),
              subtitle: Text(
                  "Subject: ${assignments[i]['subject']}\nDue: ${assignments[i]['lastDate']}"),
              trailing: IconButton(
                onPressed: (){
                  if(assignments[i]['fileType']=="pdf"){
                    preview(i, 1);
                  }else if(assignments[i]["fileType"]=="image"){
                    preview(i,0);
                  }else{

                  }
                },
                icon: Icon(
                  assignments[i]['fileType'] == 'pdf'
                      ? Icons.picture_as_pdf
                      : assignments[i]['fileType'] == 'image'
                      ? Icons.image
                      : Icons.text_snippet,
                  color: assignments[i]['fileType'] == 'pdf' ? Colors.red : Colors.blue,
                ),
                tooltip: "Preview",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentDetailPage(
                      dept: widget.dept,
                      sem: widget.sem,
                      faculty: widget.faculty,
                      subjectName: widget.subjectName,
                      assignmentKey: assignments[i]['title'],
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDeleteDialog(assignments[i]['title']);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadAssignment(
              facultyId: widget.faculty,
              department: widget.dept,
              semester: widget.sem,
              subjectId: widget.subjectName,
              subjectName: widget.subjectName,
            ),
          ),
        ).then((_) => fetchAssignments()),
        child: Icon(Icons.add),
      ),
    );
  }

  void preview(int index,int flag){
    showDialog(context: context, builder: (_){
      return Scaffold(
        body: Center(
          child: flag==0
              ?
          Image.network(assignments[index]['content'],
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text("Failed to load image\n${error.toString()}", style: TextStyle(color: Colors.red)));
            },
          )
              :
          flag==1?
          SfPdfViewer.network(
            assignments[index]['content'],
          )
              :
          null,
        ),
      );
    });
  }
}
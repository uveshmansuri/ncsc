import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Assingments extends StatefulWidget {
  var dept,sem;
  Assingments({required this.dept,required this.sem});

  @override
  State<Assingments> createState() => _AssingmentsState();
}

class _AssingmentsState extends State<Assingments> {
  List<Assignment> assignments = [];
  bool is_avil=true;
  bool is_loading=true;

  @override
  void initState() {
    fetch_assingment();
    super.initState();
  }

  void fetch_assingment() async {
    // Reference the department and semester node
    DatabaseReference ref =
    FirebaseDatabase.instance.ref('Assignments/${widget.dept}/${widget.sem}');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((subjectKey, subjectData) {
        // Each subject (e.g., "WFS") may have one or more courses (faculty)
        (subjectData as Map<dynamic, dynamic>).forEach((facultyKey, courseData) {
          // courseData now holds a map of assignments
          (courseData as Map<dynamic, dynamic>).forEach((assignmentKey, assignmentValue) async{
            var faculty_name=await FirebaseDatabase.instance
                .ref("Staff/faculty/${facultyKey.toString()}/name").get();
            assignments.add(Assignment(
              title: assignmentKey, // Title of the assignment
              content: assignmentValue['content'] as String,
              fileType: assignmentValue['fileType'] as String,
              lastDate: assignmentValue['lastDate'] as String,
              sub: subjectKey.toString(), 
              faculty: faculty_name.value.toString(), 
            ));
            setState(() {
              is_loading=false;
            });
          });
        });
      });
    }
    else{
      setState(() {
        is_loading=false;
        is_avil=false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assingments"),
      ),
      body: Stack(
        children: [
          is_loading?
          Center(
            child: CircularProgressIndicator(),
          )
              :
          Center(
            child: ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                IconData iconData;
                Color color;
                if (assignment.fileType.toLowerCase() == "image") {
                  iconData = Icons.image;
                  color=Colors.blue;
                } else if (assignment.fileType.toLowerCase() == "pdf") {
                  iconData = Icons.picture_as_pdf;
                  color=Colors.red;
                } else {
                  iconData = Icons.insert_drive_file;
                  color=Colors.blue;
                }
                return Card(
                  child: ListTile(
                    title: Text(assignment.title),
                    subtitle: Text(
                        "Subject:${assignment.sub}\nFaculty:${assignment.faculty}\nLast Date: ${assignment.lastDate}"
                    ),
                    trailing: IconButton(
                      onPressed: (){
                        int flag=0;
                        assignment.fileType=="image"?flag=0:flag=1;
                        preview(index, flag);
                      },
                      icon: Icon(iconData),
                      color: color,
                    ),
                  ),
                );
              },
            )
          ),
          if(is_avil==false)
            Center(
              child: Text(
                "Assignment is Not Published Yet",
                style: TextStyle(color: Colors.black,fontSize: 20),
              ),
            ),
        ],
      ),
    );
  }

  void preview(int index,int flag){
    showDialog(context: context, builder: (_){
      return Scaffold(
        body: Center(
          child: flag==0
              ?
          Image.network(assignments[index].content,
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
            assignments[index].content,
          )
              :
          null,
        ),
      );
    });
  }
}

class Assignment {
  final String title;
  final String content;
  final String fileType;
  final String lastDate;
  final String sub,faculty;

  Assignment({
    required this.title,
    required this.content,
    required this.fileType,
    required this.lastDate,
    required this.sub,
    required this.faculty
  });
}

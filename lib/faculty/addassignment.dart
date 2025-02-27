import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'seeallassignment.dart';

class UploadAssignment extends StatefulWidget {
  final String facultyName;
  final String department;
  final String semester;
  final List<Map<String, String>> subjects;

  UploadAssignment({
    required this.facultyName,
    required this.department,
    required this.semester,
    required this.subjects,
  });

  @override
  _UploadAssignmentState createState() => _UploadAssignmentState();
}

class _UploadAssignmentState extends State<UploadAssignment> {
  String? selectedSubjectId;
  String? selectedSubjectName;
  String? fileType;
  String? base64Image;
  String? base64Pdf;
  File? selectedFile;
  DateTime? lastDate;
  bool isUploading = false;

  final databaseRef = FirebaseDatabase.instance.ref("Assignments");
  final TextEditingController titleController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  Future<void> pickFile(bool isPdf) async {
    try {
      if (questionController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Clear the text field before uploading a file.")),
        );
        return;
      }

      if (isPdf) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null && result.files.single.path != null) {
          File file = File(result.files.single.path!);
          List<int> fileBytes = await file.readAsBytes();
          setState(() {
            selectedFile = file;
            fileType = "pdf";
            base64Pdf = base64Encode(fileBytes);
            base64Image = null;
            questionController.clear();
          });
        }
      } else {
        final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          File file = File(pickedFile.path);
          List<int> imageBytes = await file.readAsBytes();
          setState(() {
            selectedFile = file;
            fileType = "image";
            base64Image = base64Encode(imageBytes);
            base64Pdf = null;
            questionController.clear();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error selecting file: $e")));
    }
  }

  Future<void> uploadAssignment() async {
    if (selectedSubjectId == null ||
        lastDate == null ||
        titleController.text.isEmpty ||
        (questionController.text.isEmpty && base64Image == null && base64Pdf == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all details.")));
      return;
    }

    setState(() => isUploading = true);

    try {
      String department = widget.department; // Get selected department
      String semester = widget.semester; // Get selected semester
      String facultyName = widget.facultyName; // Faculty name
      String title = titleController.text; // Assignment title

      DatabaseReference ref = databaseRef
          .child(department) // Correct department
          .child(semester) // Correct semester
          .child(selectedSubjectId!) // Subject ID
          .child(facultyName)
          .child(title);

      String type = "text";
      String content = questionController.text;
      if (base64Image != null) {
        type = "image";
        content = base64Image!;
      } else if (base64Pdf != null) {
        type = "pdf";
        content = base64Pdf!;
      }

      await ref.set({
        "type": type,
        "content": content,
        "lastDate": lastDate!.toIso8601String(),
        "completed_students": {},
      });

      // Reset form after upload
      setState(() {
        selectedSubjectId = null;
        selectedSubjectName = null;
        selectedFile = null;
        base64Image = null;
        base64Pdf = null;
        fileType = null;
        lastDate = null;
        isUploading = false;
      });

      titleController.clear();
      questionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Assignment Uploaded Successfully!")));
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Assignment"),
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt),
               onPressed: () {
               Navigator.push(
               context,
               MaterialPageRoute(
               builder: (context) => AssignmentListScreen(
                       department: widget.department,
                       semester: widget.semester,
                       subject: widget.subjects,
            ),
           ),
           );},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDropdownCard(),
              SizedBox(height: 16),
              buildTitleField(),
              SizedBox(height: 16),
              buildQuestionField(),
              SizedBox(height: 16),
              buildFileUploadButtons(),
              if (selectedFile != null) buildFilePreview(),
              SizedBox(height: 16),
              buildDatePickerCard(),
              SizedBox(height: 16),
              buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdownCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          value: selectedSubjectId,
          decoration:
          InputDecoration(labelText: "Select Subject", border: InputBorder.none),
          items: widget.subjects.map((subject) {
            return DropdownMenuItem(
              value: subject['id'],
              child: Text(subject['name']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSubjectId = value;
              selectedSubjectName = widget.subjects
                  .firstWhere((subject) => subject['id'] == value)['name'];
            });
          },
        ),
      ),
    );
  }

  Widget buildTitleField() {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: "Assignment Title",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget buildQuestionField() {
    return TextField(
      controller: questionController,
      decoration: InputDecoration(
        labelText: "Enter Question (disabled if file is selected)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      maxLines: 3,
      enabled: selectedFile == null,
    );
  }

  Widget buildFileUploadButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.picture_as_pdf),
          label: Text("Upload PDF"),
          onPressed: selectedFile == null ? () => pickFile(true) : null,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text("Upload Image"),
          onPressed: selectedFile == null ? () => pickFile(false) : null,
        ),
      ],
    );
  }

  Widget buildUploadButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: isUploading ? CircularProgressIndicator() : Icon(Icons.upload),
        label: Text("Upload Assignment"),
        onPressed: isUploading ? null : uploadAssignment,
      ),
    );
  }


Widget buildFilePreview() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              fileType == "pdf" ? Icons.picture_as_pdf : Icons.image,
              size: 40,
              color: fileType == "pdf" ? Colors.red : Colors.blue,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "File Selected: ${fileType == "pdf" ? "PDF" : "Image"}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  selectedFile = null;
                  base64Image = null;
                  base64Pdf = null;
                  fileType = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDatePickerCard() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: lastDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            lastDate = pickedDate;
          });
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lastDate == null
                    ? "Select Last Date"
                    : "Last Date: ${lastDate!.toLocal()}".split(' ')[0],
                style: TextStyle(fontSize: 16),
              ),
              Icon(Icons.calendar_today, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
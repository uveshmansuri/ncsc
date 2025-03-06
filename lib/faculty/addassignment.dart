import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class Assignment {
  final DateTime lastDate;
  final String? fileType;
  final String? base64Image;
  final String? base64Pdf;
  final String? questionContent;

  Assignment({
    required this.lastDate,
    this.fileType,
    this.base64Image,
    this.base64Pdf,
    this.questionContent,
  });
  Map<String, dynamic> toMap() {
    return {
      'fileType': fileType,
      'lastDate': lastDate.toIso8601String(),
      'content': fileType == 'image' ? base64Image : (fileType == 'pdf' ? base64Pdf : questionContent),
    };
  }
}

class UploadAssignment extends StatefulWidget {
  final String facultyId;
  final String department;
  final String semester;
  final String subjectId;
  final String subjectName;

  UploadAssignment({
    required this.facultyId,
    required this.department,
    required this.semester,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  _UploadAssignmentState createState() => _UploadAssignmentState();
}

class _UploadAssignmentState extends State<UploadAssignment> {
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
          SnackBar(content: Text("Clear the text field before uploading a file.")),
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting file: $e")));
    }
  }

  Future<void> uploadAssignment() async {
    if (lastDate == null ||
        titleController.text.isEmpty ||
        (questionController.text.isEmpty &&
            base64Image == null &&
            base64Pdf == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all details.")));
      return;
    }

    setState(() => isUploading = true);

    try {
      // Create an instance of the Assignment model
      Assignment assignment = Assignment(
        lastDate: lastDate!,
        fileType: fileType,
        base64Image: base64Image,
        base64Pdf: base64Pdf,
        questionContent: questionController.text.isNotEmpty ? questionController.text : null,
      );

      DatabaseReference ref = databaseRef
          .child(widget.department)
          .child(widget.semester)
          .child(widget.subjectId)
          .child(widget.facultyId)
          .child(titleController.text);

      await ref.set(assignment.toMap());

      setState(() {
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Upload Assignment for ${widget.subjectName}")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      child: Text("Last Date: ${lastDate != null ? lastDate!.toLocal().toString().split(' ')[0] : "Select Last Date"}"),
    );
  }

}
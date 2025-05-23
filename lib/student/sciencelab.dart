import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class ScienceLabQueryPage extends StatefulWidget {
  final String stud_id;
  final String dept;

  ScienceLabQueryPage({required this.stud_id, required this.dept});

  @override
  _ScienceLabQueryPageState createState() => _ScienceLabQueryPageState();
}

class _ScienceLabQueryPageState extends State<ScienceLabQueryPage> {
  List<Map<String, dynamic>> _queries = [];
  bool isLoading = true;
  String studentName = "";

  @override
  void initState() {
    super.initState();
    fetchStudentName();
    fetchQueries();
  }

  Future<void> fetchStudentName() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Students/${widget.stud_id}");
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        setState(() {
          studentName = snapshot.child("name").value.toString();
        });
      } else {
        print("Student not found");
      }
    } catch (e) {
      print("Error fetching student name: $e");
    }
  }

  Future<void> fetchQueries() async {
    setState(() => isLoading = true);
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Query/sciencelab/${widget.stud_id}");
      DataSnapshot snapshot = await ref.get();

      List<Map<String, dynamic>> queryList = [];
      if (snapshot.exists) {
        snapshot.children.forEach((child) {
          Map<String, dynamic> queryData = Map<String, dynamic>.from(child.value as Map);
          queryData['key'] = child.key!;
          queryList.add(queryData);
        });
      }

      setState(() {
        _queries = queryList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching queries: $e");
      setState(() => isLoading = false);
    }
  }

  void _showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PhotoView(imageProvider: NetworkImage(imageUrl)),
      ),
    );
  }
  void _showEditDialog(Map<String, dynamic> query) {
    TextEditingController pcController = TextEditingController(text: query['pcnumber']);
    TextEditingController descController = TextEditingController(text: query['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Science Lab Query"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pcController,
              decoration: InputDecoration(labelText: "PC Number"),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _editQuery(query['key'], pcController.text, descController.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
  Future<void> _editQuery(String key, String pcNumber, String description) async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Query/sciencelab/${widget.stud_id}/$key");

      await ref.update({
        'pcnumber': pcNumber,
        'description': description,
      });

      fetchQueries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Query updated successfully")),
      );
    } catch (e) {
      print("Error updating query: $e");
    }
  }


  void _showDeleteConfirmationDialog(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Query"),
        content: Text("Are you sure you want to delete this query?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteQuery(key);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteQuery(String key) async {
    try {
      await FirebaseDatabase.instance.ref("Query/sciencelab/${widget.stud_id}/$key").remove();
      fetchQueries();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Query deleted successfully")),
      );
    } catch (e) {
      print("Error deleting query: $e");
    }
  }

  Widget _buildQueryCard(Map<String, dynamic> query) {
    return Dismissible(
      key: Key(query['key']),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.green,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      onDismissed: (direction) {
        _showEditDialog(query);
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text(
            "PC Number: ${query['pcnumber']}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Description: ${query['description']}"),
          trailing: query.containsKey('image') && query['image'].isNotEmpty
              ? IconButton(
            icon: Icon(Icons.image, color: Colors.blue),
            onPressed: () => _showImage(query['image']),
          )
              : null,
          onLongPress: () => _showDeleteConfirmationDialog(query['key']),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Science Lab Queries'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _queries.isEmpty
          ? Center(child: Text("No Queries Available"))
          : ListView.builder(
        itemCount: _queries.length,
        itemBuilder: (context, index) {
          return _buildQueryCard(_queries[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateScienceQueryPage(
                stud_id: widget.stud_id,
                dept: widget.dept,
              ),
            ),
          );
          fetchQueries();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );

  }
}

//sciencelab


class CreateScienceQueryPage extends StatefulWidget {
  final String stud_id;
  final String dept;
  final Map<String, dynamic>? existingQuery;

  CreateScienceQueryPage({required this.stud_id, required this.dept, this.existingQuery});

  @override
  _CreateScienceLabQueryPageState createState() => _CreateScienceLabQueryPageState();
}

class _CreateScienceLabQueryPageState extends State<CreateScienceQueryPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController pcNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? _imageFile;
  String? imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuery != null) {
      pcNumberController.text = widget.existingQuery!['pcnumber'] ?? '';
      descriptionController.text = widget.existingQuery!['description'] ?? '';
      imageUrl = widget.existingQuery!['image'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String imageName = "query_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child("science_queries/$imageName");
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      String labType = "sciencelab";
      String? uploadedImageUrl;

      if (_imageFile != null) {
        uploadedImageUrl = await _uploadImage(_imageFile!);
      }

      Map<String, dynamic> queryData = {
        'pcnumber': pcNumberController.text,
        'description': descriptionController.text,
      };

      if (uploadedImageUrl != null && uploadedImageUrl.isNotEmpty) {
        queryData['image'] = uploadedImageUrl;
      }

      DatabaseReference ref = FirebaseDatabase.instance
          .ref("Query/$labType/${widget.stud_id}")
          .push();
      await ref.set(queryData);

      Navigator.pop(context);
    } catch (e) {
      print("Error submitting query: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create/Edit Science Lab Query")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: pcNumberController,
                decoration: InputDecoration(labelText: 'Subject'),
                validator: (value) => value!.isEmpty ? 'Please enter Subject number' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150, width: 150),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitQuery,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';


class LabQueryPage extends StatefulWidget {
  final String stud_id;
  final String dept;

  LabQueryPage({required this.stud_id, required this.dept});

  @override
  _LabQueryPageState createState() => _LabQueryPageState();
}

class _LabQueryPageState extends State<LabQueryPage> {
  List<Map<String, dynamic>> _queries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQueries();
  }

  Future<void> fetchQueries() async {
    setState(() => isLoading = true);
    try {
      String labType = widget.dept == "BCA" ? "computerlab" : "sciencelab";
      DatabaseReference ref = FirebaseDatabase.instance.ref("Query/$labType");
      DataSnapshot snapshot = await ref.get();

      List<Map<String, dynamic>> queryList = [];
      if (snapshot.exists) {
        snapshot.children.forEach((child) {
          Map<String, dynamic> queryData = Map<String, dynamic>.from(child.value as Map);
          if (queryData["stud_id"] == widget.stud_id) {
            queryData['key'] = child.key;
            queryList.add(queryData);
          }
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

  Future<void> deleteQuery(String key) async {
    try {
      String labType = widget.dept == "BCA" ? "computerlab" : "sciencelab";
      await FirebaseDatabase.instance.ref("Query/$labType/$key").remove();
      fetchQueries();
    } catch (e) {
      print("Error deleting query: $e");
    }
  }

  void _editQuery(Map<String, dynamic> query) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLabQueryPage(
          stud_id: widget.stud_id,
          dept: widget.dept,
          existingQuery: query,
        ),
      ),
    );
    fetchQueries();
  }

  Widget _buildQueryCard(Map<String, dynamic> query) {
    return Dismissible(
      key: Key(query['key']),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _editQuery(query);
        } else if (direction == DismissDirection.endToStart) {
          deleteQuery(query['key']);
        }
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text("PC Number: ${query['pcnumber']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Description: ${query['description']}", style: TextStyle(fontSize: 16)),
              Text("Student Name: ${query['nameofstud']}", style: TextStyle(fontSize: 16)),
              if (query.containsKey('image') && query['image'].isNotEmpty)
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blue),
                  onPressed: () => _showImage(query['image']),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Queries'),
        backgroundColor: Colors.blue,
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateLabQueryPage(
                stud_id: widget.stud_id,
                dept: widget.dept,
              ),
            ),
          );
          fetchQueries();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}




class CreateLabQueryPage extends StatefulWidget {
  final String stud_id;
  final String dept;
  final Map<String, dynamic>? existingQuery;

  CreateLabQueryPage({required this.stud_id, required this.dept, this.existingQuery});

  @override
  _CreateLabQueryPageState createState() => _CreateLabQueryPageState();
}

class _CreateLabQueryPageState extends State<CreateLabQueryPage> {
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
      Reference ref = FirebaseStorage.instance.ref().child("queries/$imageName");
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
      String labType = widget.dept == "BCA" ? "computerlab" : "sciencelab";
      String? uploadedImageUrl;

      if (_imageFile != null) {
        uploadedImageUrl = await _uploadImage(_imageFile!);
      }

      DatabaseReference ref = widget.existingQuery != null
          ? FirebaseDatabase.instance.ref("Query/$labType/${widget.existingQuery!['key']}")
          : FirebaseDatabase.instance.ref("Query/$labType").push();

      await ref.set({
        'pcnumber': pcNumberController.text,
        'description': descriptionController.text,
        'nameofstud': "Student Name", // Replace with actual student name
        if (uploadedImageUrl != null) 'image': uploadedImageUrl,
      });

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
      appBar: AppBar(
        title: Text(widget.existingQuery != null ? "Edit Lab Query" : "Create Lab Query"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: pcNumberController,
                decoration: InputDecoration(labelText: 'PC Number'),
                validator: (value) => value!.isEmpty ? 'Please enter PC number' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              SizedBox(height: 20),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
                  : imageUrl != null
                  ? Image.network(imageUrl!, height: 150, fit: BoxFit.cover)
                  : Text("No Image Selected"),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Pick Image"),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitQuery,
                child: Text(widget.existingQuery != null ? "Update Query" : "Submit Query"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

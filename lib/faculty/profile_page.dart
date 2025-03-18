import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import '../logout.dart';

class ProfilePage extends StatefulWidget {
  final String fid;
  ProfilePage(this.fid);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? facultyData;
  bool isLoading = true;
  File? _imageFile;
  String? _base64Image;
  final _imgPicker = ImagePicker();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFacultyDetails();
  }

  void fetchFacultyDetails() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Staff/faculty/${widget.fid}");

    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          facultyData = Map<String, dynamic>.from(data);
          phoneController.text = facultyData!["phone"] ?? "";
          addressController.text = facultyData!["address"] ?? "";
          experienceController.text = facultyData!["experience"] ?? "";
          _base64Image = facultyData!["image"];
          isLoading = false;
        });
      } else {
        setState(() {
          facultyData = null;
          isLoading = false;
        });
      }
    }, onError: (error) {
      print("Error fetching data: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _pickImage(Function(String) onImagePicked) async {
    final pickedFile = await _imgPicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      String encodedImage = base64Encode(bytes);
      onImagePicked(encodedImage);
    }
  }

  void saveDetails(String? updatedImage) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Staff/faculty/${widget.fid}");
    ref.update({
      "phone": phoneController.text,
      "address": addressController.text,
      "experience": experienceController.text,
      "image": updatedImage ?? _base64Image ?? ""
    }).then((_) {
      setState(() {
        _base64Image = updatedImage ?? _base64Image;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile.")));
    });
  }

  void showEditDialog() {
    String? tempImage = _base64Image;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage((image) {
                        setStateDialog(() {
                          tempImage = image;
                        });
                      }),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: tempImage != null
                            ? MemoryImage(base64Decode(tempImage!))
                            : null,
                        backgroundColor: Colors.blueAccent,
                        child: tempImage == null
                            ? Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: "Phone"),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(labelText: "Address"),
                    ),
                    TextField(
                      controller: experienceController,
                      decoration: InputDecoration(labelText: "Experience"),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => saveDetails(tempImage),
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Faculty Profile"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: showEditDialog,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : facultyData == null
          ? Center(child: Text("No data found for this faculty"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _base64Image != null
                        ? MemoryImage(base64Decode(_base64Image!))
                        : null,
                    backgroundColor: Colors.blueAccent,
                    child: _base64Image == null
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                buildProfileRow("Name", facultyData!["name"]),
                buildProfileRow("Email", facultyData!["email"]),
                buildProfileRow("Department", facultyData!["department"]),
                buildProfileRow("Post", facultyData!["post"]),
                buildProfileRow("Qualification", facultyData!["qualification"]),
                buildProfileRow("Experience", facultyData!["experience"] ?? "Not Available"),
                buildProfileRow("Phone", facultyData!["phone"] ?? "Not Available"),
                buildProfileRow("Address", facultyData!["address"] ?? "Not Available"),
                Center(
                  child: ElevatedButton(
                    onPressed: (){
                      logout obj=logout();
                      obj.show_dialouge(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout),
                        Text("Logout")
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

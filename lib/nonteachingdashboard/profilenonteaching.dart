import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:NCSC/logout.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  Future<void> fetchProfileDetails() async {
    try {
      String key = widget.username.trim().toUpperCase();
      DatabaseEvent event = await _dbRef.child('Staff/non_teaching/$key').once();
      var data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          phoneController.text = data['phone']?.toString() ?? '';
          addressController.text = data['address']?.toString() ?? '';
          qualificationController.text = data['qualification']?.toString() ?? '';
          _base64Image = data['profileI']?.toString();
        });
      }
    } catch (e) {
      print("Error fetching profile details: $e");
    }
  }

  Future<void> updateProfileDetails(String address, String phone, String? profileImage) async {
    final databaseRef = FirebaseDatabase.instance.ref().child('Staff/non_teaching/${widget.username.trim().toUpperCase()}');
    await databaseRef.update({
      'address': address,
      'phone': phone,
      if (profileImage != null) 'profileI': profileImage,
    });

    setState(() {
      _base64Image = profileImage ?? _base64Image;
    });

    Navigator.of(context).pop();
  }

  Future<String?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  void showEditDialog() {
    String? tempImage = _base64Image;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? image = await pickImage();
                        setStateDialog(() {
                          tempImage = image;
                        });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: tempImage != null
                            ? MemoryImage(base64Decode(tempImage!))
                            : null,
                        child: tempImage == null ? Icon(Icons.person, size: 50) : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone"), keyboardType: TextInputType.phone),
                    SizedBox(height: 15),
                    TextField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
                    SizedBox(height: 15),
                    TextField(controller: qualificationController, decoration: InputDecoration(labelText: "Qualification")),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(onPressed: () => saveDetails(tempImage), child: Text("Save")),
          ],
        );
      },
    );
  }

  Future<void> saveDetails(String? tempImage) async {
    try {
      await _dbRef.child('Staff/non_teaching/${widget.username.trim().toUpperCase()}').update({
        'phone': phoneController.text,
        'address': addressController.text,
        'qualification': qualificationController.text,
        'profileI': tempImage ?? '',
      });

      setState(() {
        _base64Image = tempImage;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page "),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: showEditDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _base64Image != null ? MemoryImage(base64Decode(_base64Image!)) : null,
              child: _base64Image == null ? Icon(Icons.person, size: 50) : null,
            ),
            SizedBox(height: 20),
            Text(widget.username, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.phone),
                title: Text("Phone"),
                subtitle: Text(phoneController.text),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text("Address"),
                subtitle: Text(addressController.text),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.school),
                title: Text("Qualification"),
                subtitle: Text(qualificationController.text),
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  logout obj = logout();
                  obj.show_dialouge(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8), // Space between icon and text
                    Text("Logout"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  }

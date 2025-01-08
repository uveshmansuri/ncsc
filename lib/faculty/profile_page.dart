import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? uid, name, email, quali, dept, post, phone, address;
  String? profileImageBase64;
  String? temProfileImageBase64;
  bool isEditing = false;

  final TextEditingController namebox = TextEditingController();
  final TextEditingController emailbox = TextEditingController();
  final TextEditingController qualibox = TextEditingController();
  final TextEditingController phonebox = TextEditingController();
  final TextEditingController addbox = TextEditingController();

  DatabaseReference? profileRef;

  @override
  void initState() {
    super.initState();
    loadUid();
  }

  Future<void> loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uname');
    if (uid != null) {
      profileRef = FirebaseDatabase.instance.ref("Faculties/$uid");
      profileRef?.onValue.listen((event) {
        if (event.snapshot.exists) {
          var data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            name = data['name']?.toString();
            email = data['email']?.toString();
            quali = data['qualification']?.toString();
            dept = data['department']?.toString();
            post = data['post']?.toString();
            phone = data['phone']?.toString();
            address = data['address']?.toString();
            profileImageBase64 = data['img']?.toString();

            namebox.text = name ?? '';
            emailbox.text = email ?? '';
            qualibox.text = quali ?? '';
            phonebox.text = phone ?? '';
            addbox.text = address ?? '';
          });
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (uid != null) {
      try {
        await profileRef?.update({
          "name": namebox.text,
          "email": emailbox.text,
          "qualification": qualibox.text,
          "phone": phonebox.text,
          "address": addbox.text,
          "img": profileImageBase64 ?? '',
        });
        setState(() {
          profileImageBase64 = temProfileImageBase64;
          isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );
      } catch (e) {
        print("Error updating profile: $e");
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64String = base64Encode(imageBytes);
        setState(() {
          temProfileImageBase64 = base64String;
        });
      } catch (e) {
        print("Error converting image to Base64: $e");
      }
    }
  }

  void EditDialog() {
    temProfileImageBase64 = profileImageBase64;

    String initialPhone = phonebox.text;
    String initialAddress = addbox.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await pickImage();
                          setState(() {});
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: temProfileImageBase64 != null
                              ? MemoryImage(base64Decode(temProfileImageBase64!))
                              : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 15,
                              child: Icon(Icons.edit, color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: phonebox,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: addbox,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              phonebox.text = initialPhone;
                              addbox.text = initialAddress;
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                profileImageBase64 = temProfileImageBase64;
                              });
                              _saveChanges();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.lightBlue.shade700,
        elevation: 4.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: EditDialog,
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Color(0xffd1fbff),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: name == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageBase64 != null
                      ? MemoryImage(base64Decode(profileImageBase64!))
                      : AssetImage('assets/profile_placeholder.png') as ImageProvider,
                ),
                SizedBox(height: 20),
                EditableField(Icons.person, namebox),
                EditableField(Icons.email, emailbox),
                StaticField(Icons.business, dept ?? ""),
                StaticField(Icons.work, post ?? ""),
                EditableField(Icons.school, qualibox),
                if (phone != null && phone!.isNotEmpty)
                  EditableField(Icons.phone, phonebox),
                if (address != null && address!.isNotEmpty)
                 EditableField(Icons.home, addbox),
                if (isEditing) SizedBox(height: 30),
                if (isEditing)
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text("Save Changes"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade800,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget EditableField(IconData icon, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.lightBlue.shade800),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
        controller: controller,
        enabled: isEditing,
      ),
    );
  }

  Widget StaticField(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.lightBlue.shade800),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black87),
        controller: TextEditingController(text: value),
        enabled: false,
      ),
    );
  }
}

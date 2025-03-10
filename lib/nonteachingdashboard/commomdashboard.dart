import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'circularnonteaching.dart';
import 'clerkpage.dart';
import 'complainnonteaching.dart';
import 'computerlabdashboard.dart';
import 'officesupriender.dart';
import 'sciencelabdashboard.dart';

class RoleBasedDashboard extends StatefulWidget {
  final String username;
  RoleBasedDashboard({Key? key, required this.username}) : super(key: key);

  @override
  _RoleBasedDashboardState createState() => _RoleBasedDashboardState();
}

class _RoleBasedDashboardState extends State<RoleBasedDashboard> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<String> userRoles = [];
  bool isLoading = true;

  // Controllers for profile editing
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();

  // Profile image stored as a base64 string
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    // Fetch roles and profile details from Firebase.
    fetchUserRoles();
    fetchProfileDetails();
  }

  Future<void> fetchUserRoles() async {
    try {
      // Convert the username to uppercase if your keys are stored that way.
      String key = widget.username.trim().toUpperCase();
      print("Querying roles for non_teaching with key: $key");

      DatabaseEvent event = await _dbRef
          .child('Staff')
          .child('non_teaching')
          .child(key)
          .child('roles')
          .once();
      print("Fetched roles snapshot: ${event.snapshot.value}");
      var rolesData = event.snapshot.value;
      List<String> rolesList = [];
      if (rolesData != null) {
        if (rolesData is List) {
          rolesList = List<String>.from(rolesData.where((role) => role != null));
        } else if (rolesData is Map) {
          var sortedKeys = rolesData.keys.toList()..sort();
          for (var k in sortedKeys) {
            if (rolesData[k] != null) {
              rolesList.add(rolesData[k].toString());
            }
          }
        } else {
          rolesList.add(rolesData.toString());
        }
      }
      setState(() {
        userRoles = rolesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching roles: $e");
    }
  }

  Future<void> fetchProfileDetails() async {
    try {
      String key = widget.username.trim().toUpperCase();
      DatabaseEvent event = await _dbRef
          .child('Staff')
          .child('non_teaching')
          .child(key)
          .once();
      // Assuming profile details are stored as key/value pairs in this node.
      var data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          phoneController.text = data['phone']?.toString() ?? '';
          addressController.text = data['address']?.toString() ?? '';
          qualificationController.text = data['qualification']?.toString() ?? '';
          _base64Image = data['profileImage']?.toString();
        });
      }
    } catch (e) {
      print("Error fetching profile details: $e");
    }
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget buildDashboardItem({
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => navigateToPage(context, page),
      ),
    );
  }

  // Method to show the edit dialog for profile
  void showEditDialog() {
    // Use a temporary variable to hold the new image before saving.
    String? tempImage = _base64Image;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tap to pick a new image
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
                    SizedBox(height: 20),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: qualificationController,
                      decoration: InputDecoration(
                        labelText: "Qualification",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
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

  // Use image_picker package to pick an image from the gallery.
  Future<void> _pickImage(Function(String image) callback) async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      callback(base64Image);
    }
  }

  // Save updated profile details to Firebase under non-teaching staff.
  Future<void> saveDetails(String? tempImage) async {
    setState(() {
      _base64Image = tempImage;
    });
    String key = widget.username.trim().toUpperCase();
    try {
      await _dbRef.child('Staff').child('non_teaching').child(key).update({
        'phone': phoneController.text,
        'address': addressController.text,
        'qualification': qualificationController.text,
        'profileImage': _base64Image,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")));
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update profile")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String rolesDisplay =
    userRoles.isNotEmpty ? userRoles.join(", ") : "Unknown";
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: [
          // Profile icon on top-right opens the edit dialog.
          IconButton(
            icon: CircleAvatar(
              backgroundImage: _base64Image != null
                  ? MemoryImage(base64Decode(_base64Image!))
                  : null,
              backgroundColor: Colors.white,
              child: _base64Image == null
                  ? Icon(Icons.person, color: Colors.blue)
                  : null,
            ),
            onPressed: showEditDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header card displaying the username and roles.
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    widget.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                title: Text(
                  "Welcome, ${widget.username}",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Roles: $rolesDisplay"),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildDashboardItem(
                    title: "Circular",
                    icon: Icons.campaign,
                    page: circularnonteaching(),
                  ),
                  buildDashboardItem(
                    title: "Complaint",
                    icon: Icons.report_problem,
                    page: complainnonteaching(),
                  ),
                  if (userRoles.contains("Lab Assistant"))
                    buildDashboardItem(
                      title: "Lab Assistant Page",
                      icon: Icons.computer,
                      page: computerlabdashboard(),
                    ),
                  if (userRoles.contains("science_lab_assistant"))
                    buildDashboardItem(
                      title: "Science Lab Page",
                      icon: Icons.science,
                      page: sciencelab(),
                    ),
                  if (userRoles.contains("Clerk"))
                    buildDashboardItem(
                      title: "Clerk Page",
                      icon: Icons.assignment_ind,
                      page: ClerkPage(),
                    ),
                  if (userRoles.contains("office_superintendent"))
                    buildDashboardItem(
                      title: "Office Superintendent Page",
                      icon: Icons.apartment,
                      page: OfficeSuperintendentPage(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddTeachingStaff extends StatefulWidget {
  @override
  _AddTeachingStaffState createState() => _AddTeachingStaffState();
}

class _AddTeachingStaffState extends State<AddTeachingStaff> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.ref();

  String? selectedDepartment;
  Map<String, String> departments = {}; // Stores department ID -> Name mapping
  List<String> selectedRoles = []; // Stores selected roles

  // Role options
  final List<String> roles = ["Professor", "Assistant", "HOD"];

  @override
  void initState() {
    super.initState();
  }

  // Fetch department data from Firebase with FutureBuilder
  Future<Map<String, String>> _fetchDepartments() async {
    final dataSnapshot = await databaseReference.child("department").get();
    Map<String, String> loadedDepartments = {};

    if (dataSnapshot.exists) {
      final data = dataSnapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        loadedDepartments[key] = value['department'];
      });
    }
    return loadedDepartments;
  }

  // Add teaching staff to Firebase
  void _addTeachingStaff() {
    String name = _nameController.text.trim();
    String id = _idController.text.trim();
    String email = _emailController.text.trim();
    String qualification = _qualificationController.text.trim();
    String details = _detailsController.text.trim();

    if (id.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        qualification.isNotEmpty &&
        details.isNotEmpty &&
        selectedDepartment != null &&
        selectedRoles.isNotEmpty) {
      // Save data under ID instead of random key
      databaseReference.child("faculty/teaching/$id").set({
        'name': name,
        'email': email,
        'qualification': qualification,
        'details': details,
        'department': selectedDepartment, // Store selected department
        'roles': selectedRoles, // Store selected roles
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Teaching Staff Added Successfully!')));
        // Clear fields after saving
        _nameController.clear();
        _idController.clear();
        _emailController.clear();
        _qualificationController.clear();
        _detailsController.clear();
        setState(() {
          selectedRoles.clear(); // Clear selected roles
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add teaching staff: $error')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields and select at least one role')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Teaching Staff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          shadowColor: Colors.deepPurpleAccent,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_idController, "Enter ID", Icons.badge),
                _buildTextField(_nameController, "Enter Name", Icons.person),
                _buildTextField(_emailController, "Enter Email", Icons.email, isEmail: true),
                _buildTextField(_qualificationController, "Enter Qualification", Icons.school),
                _buildTextField(_detailsController, "Enter Teacher Details", Icons.info),
                SizedBox(height: 20),
                Divider(),
                // Use FutureBuilder to Fetch Departments
                Text("Select Department", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                FutureBuilder<Map<String, String>>(
                  future: _fetchDepartments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text("Error loading departments");
                    }
                    Map<String, String> deptList = snapshot.data ?? {};
                    if (deptList.isEmpty) {
                      return Text("No departments available");
                    }
                    return DropdownButtonFormField<String>(
                      value: selectedDepartment ?? deptList.values.first,
                      items: deptList.entries.map((dept) {
                        return DropdownMenuItem<String>(
                          value: dept.value,
                          child: Text(dept.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Divider(),
                // Role Selection with Checkboxes
                Text("Select Roles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children: roles.map((role) {
                    return CheckboxListTile(
                      title: Text(role),
                      value: selectedRoles.contains(role),
                      activeColor: Colors.deepPurple,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedRoles.add(role);
                          } else {
                            selectedRoles.remove(role);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),
                Divider(),
                // Submit Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addTeachingStaff,
                    icon: Icon(Icons.add, size: 24),
                    label: Text("Add Staff", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // Helper method for text fields
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}

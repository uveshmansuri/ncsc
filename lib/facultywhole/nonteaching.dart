import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddNonTeachingStaff extends StatefulWidget {
  @override
  _AddNonTeachingStaffState createState() => _AddNonTeachingStaffState();
}

class _AddNonTeachingStaffState extends State<AddNonTeachingStaff> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.ref();

  List<String> selectedRoles = [];
  final List<String> roles = ["Clerk", "Librarian", "Lab Assistant"];

  // Function to add Non-Teaching Staff to Firebase
  void _addNonTeachingStaff() {
    String id = _idController.text.trim();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String qualification = _qualificationController.text.trim();
    String details = _detailsController.text.trim();

    if (id.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        qualification.isNotEmpty &&
        details.isNotEmpty &&
        selectedRoles.isNotEmpty) {

      // Save to faculty/non_teaching/{id}
      databaseReference.child("faculty/non_teaching/$id").set({
        'name': name,
        'email': email,
        'password': password,
        'qualification': qualification,
        'details': details,
        'roles': selectedRoles, // Save selected roles
      });

      // Save to Users/{id}
      databaseReference.child("Users/$id").set({
        'name': name,
        'password': password,
        'roles': selectedRoles,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Non-Teaching Staff Added Successfully!')));

        // Clear fields after saving
        _idController.clear();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _qualificationController.clear();
        _detailsController.clear();
        setState(() {
          selectedRoles.clear();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add non-teaching staff: $error')));
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
        title: Text('Add Non-Teaching Staff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          shadowColor: Colors.blueAccent,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_idController, "Enter ID", Icons.badge),
                _buildTextField(_nameController, "Enter Name", Icons.person),
                _buildTextField(_emailController, "Enter Email", Icons.email, isEmail: true),
                _buildTextField(_passwordController, "Enter Password", Icons.lock, isPassword: true),
                _buildTextField(_qualificationController, "Enter Qualification", Icons.school),
                _buildTextField(_detailsController, "Enter Details", Icons.info),

                SizedBox(height: 20),
                Divider(),

                // Role Selection with Checkboxes
                Text("Select Roles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Column(
                  children: roles.map((role) {
                    return CheckboxListTile(
                      title: Text(role),
                      value: selectedRoles.contains(role),
                      activeColor: Colors.blueAccent,
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
                    onPressed: _addNonTeachingStaff,
                    icon: Icon(Icons.add, size: 24),
                    label: Text("Add Staff", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}

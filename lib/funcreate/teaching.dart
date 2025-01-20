import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TeachingStaffList extends StatelessWidget {
  final List<Map<String, String>> staffList;

  const TeachingStaffList({required this.staffList, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return staffList.isEmpty
        ? const Center(
      child: Text('No Teaching Staff added yet.'),
    )
        : ListView.builder(
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final staff = staffList[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(staff['name'] ?? 'N/A'),
          subtitle: Text('Dept: ${staff['department'] ?? 'N/A'}'),
        );
      },
    );
  }
}

class AddTeachingStaffScreen extends StatefulWidget {
  @override
  _AddTeachingStaffScreenState createState() =>
      _AddTeachingStaffScreenState();
}

class _AddTeachingStaffScreenState extends State<AddTeachingStaffScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedDepartment;
  List<String> _selectedRoles = [];

  final DatabaseReference _database = FirebaseDatabase.instance.ref('teachingstaff');

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Teaching Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person,
                  ),
                  _buildTextField(
                    controller: _idController,
                    label: 'ID',
                    icon: Icons.badge,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                  ),
                  _buildTextField(
                    controller: _qualificationController,
                    label: 'Qualification',
                    icon: Icons.school,
                  ),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    icon: Icons.text_snippet,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedDepartment,
                    label: 'Select Department',
                    items: const ['Computer Science', 'Mathematics', 'Physics'],
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMultiSelectRoles(
                    roles: const ['Professor', 'Assistant', 'H.O.D'],
                    selectedRoles: _selectedRoles,
                    title: 'Select Roles',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addStaff,
                    child: const Text('Add Teaching Staff'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMultiSelectRoles({
    required List<String> roles,
    required List<String> selectedRoles,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...roles.map((role) {
          return CheckboxListTile(
            title: Text(role),
            value: selectedRoles.contains(role),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected == true) {
                  selectedRoles.add(role);
                } else {
                  selectedRoles.remove(role);
                }
              });
            },
          );
        }).toList(),
      ],
    );
  }

  void _addStaff() async {
    if (_nameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields!')),
      );
      return;
    }

    final newStaff = {
      'name': _nameController.text,
      'id': _idController.text,
      'email': _emailController.text,
      'qualification': _qualificationController.text,
      'bio': _bioController.text,
      'department': _selectedDepartment,
      'roles': _selectedRoles,
    };

    try {
      // Push data to the 'teachingstaff' node in Firebase
      await _database.push().set(newStaff);
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding staff: $error')),
      );
    }
  }
}

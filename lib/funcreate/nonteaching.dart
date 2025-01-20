import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NonTeachingStaffScreen extends StatefulWidget {
  @override
  _NonTeachingStaffScreenState createState() => _NonTeachingStaffScreenState();}

class _NonTeachingStaffScreenState extends State<NonTeachingStaffScreen> {
  final DatabaseReference _database =
  FirebaseDatabase.instance.ref('nonteachingstaff');
  List<Map<String, String>> _staffList = [];

  @override
  void initState() {

    super.initState();
    _fetchStaffList();
  }

  void _fetchStaffList() async {
    final snapshot = await _database.get();
    if (snapshot.exists) {
      final staffMap = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _staffList = staffMap.entries.map((entry) {
          final staff = entry.value as Map<dynamic, dynamic>;
          return {
            'name': staff['name']?.toString() ?? 'N/A',
            'id': staff['id']?.toString() ?? 'N/A',
            'department': staff['department']?.toString() ?? 'N/A',
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _staffList.isEmpty
          ? const Center(child: Text('No Non-Teaching Staff added yet.'))
          : ListView.builder(
        itemCount: _staffList.length,
        itemBuilder: (context, index) {
          final staff = _staffList[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(staff['name'] ?? 'N/A'),
            subtitle: Text('Dept: ${staff['department'] ?? 'N/A'}'),
            onTap: () {
              // On item tap, navigate to the form to edit or add staff
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNonTeachingStaffFormScreen(
                    staff: staff,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddNonTeachingStaffFormScreen extends StatefulWidget {
  final Map<String, String>? staff;

  const AddNonTeachingStaffFormScreen({Key? key, this.staff}) : super(key: key);

  @override
  _AddNonTeachingStaffFormScreenState createState() =>
      _AddNonTeachingStaffFormScreenState();
}

class _AddNonTeachingStaffFormScreenState
    extends State<AddNonTeachingStaffFormScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _detailsController = TextEditingController();
  final _qualificationController = TextEditingController();
  String? _selectedDepartment;
  List<String> _selectedRoles = [];

  final DatabaseReference _database =
  FirebaseDatabase.instance.ref('nonteachingstaff');

  @override
  void initState() {
    super.initState();

    if (widget.staff != null) {
      // If editing an existing staff member, populate the fields with current data
      _nameController.text = widget.staff!['name']!;
      _idController.text = widget.staff!['id']!;
      _emailController.text = widget.staff!['email'] ?? '';
      _detailsController.text = widget.staff!['details'] ?? '';
      _qualificationController.text = widget.staff!['qualification'] ?? '';
      _selectedDepartment = widget.staff!['department'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _detailsController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  void _saveStaff() async {
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
      'details': _detailsController.text,
      'qualification': _qualificationController.text,
      'department': _selectedDepartment,
      'roles': _selectedRoles,
    };

    try {
      if (widget.staff == null) {
        // If no existing staff, add a new one
        await _database.push().set(newStaff);
      } else {
        // If editing, update the existing staff member
        await _database.child(widget.staff!['id']!).update(newStaff);
      }
      Navigator.pop(context); // Go back to the staff list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving staff: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.staff == null
            ? const Text('Add Non-Teaching Staff')
            : const Text('Edit Non-Teaching Staff'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                controller: _detailsController,
                label: 'Personal Details',
                icon: Icons.description,
                maxLines: 3,
              ),
              _buildTextField(
                controller: _qualificationController,
                label: 'Qualification',
                icon: Icons.school,
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedDepartment,
                label: 'Select Department',
                items: const ['Admin', 'Accounts', 'Maintenance'],
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildMultiSelectRoles(
                roles: const [
                  'Office Superintendent',
                  'Senior Clerk',
                  'Jr Clerk',
                  'Worker'
                ],
                selectedRoles: _selectedRoles,
                title: 'Select Roles',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveStaff,
                child: widget.staff == null
                    ? const Text('Add Non-Teaching Staff')
                    : const Text('Update Non-Teaching Staff'),
              ),
            ],
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
}

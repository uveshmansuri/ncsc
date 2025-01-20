import 'package:flutter/material.dart';

class FacultyPage extends StatefulWidget {
  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();

  String selectedRole = 'Teaching';
  int _facultyCounter = 1;

  // Lists to separate teaching and non-teaching faculty
  List<Map<String, String>> teachingFacultyList = [];
  List<Map<String, String>> nonTeachingFacultyList = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Generate unique faculty ID
  String _generateFacultyId() {
    return "FAC${_facultyCounter.toString().padLeft(3, '0')}";
  }

  // Add Faculty Method
  void _addFaculty() {
    String facultyId = _generateFacultyId();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String address = _addressController.text.trim();
    String qualification = _qualificationController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && address.isNotEmpty && qualification.isNotEmpty) {
      Map<String, String> faculty = {
        'faculty_id': facultyId,
        'name': name,
        'email': email,
        'address': address,
        'qualification': qualification,
        'role': selectedRole,
      };

      setState(() {
        if (selectedRole == 'Teaching') {
          teachingFacultyList.add(faculty);
        } else {
          nonTeachingFacultyList.add(faculty);
        }
        _facultyCounter++;
      });

      // Clear input fields
      _nameController.clear();
      _emailController.clear();
      _addressController.clear();
      _qualificationController.clear();
      selectedRole = 'Teaching';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teaching'),
            Tab(text: 'Non-Teaching'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFacultyList(teachingFacultyList),
          _buildFacultyList(nonTeachingFacultyList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFacultyDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget to build the faculty list for each tab
  Widget _buildFacultyList(List<Map<String, String>> facultyList) {
    return ListView.builder(
      itemCount: facultyList.length,
      itemBuilder: (context, index) {
        final faculty = facultyList[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                faculty['faculty_id']!.substring(3),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(faculty['name']!),
            subtitle: Text(
              'Email: ${faculty['email']}\nAddress: ${faculty['address']}\nQualification: ${faculty['qualification']}\nRole: ${faculty['role']}',
            ),
          ),
        );
      },
    );
  }

  // Dialog to add a new faculty
  void _showAddFacultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Faculty'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Faculty Name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Faculty Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Email ID
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12.0),

                // Address
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12.0),

                // Qualification
                TextField(
                  controller: _qualificationController,
                  decoration: const InputDecoration(
                    labelText: 'Qualification',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'Teaching', child: Text('Teaching')),
                    DropdownMenuItem(value: 'Non-Teaching', child: Text('Non-Teaching')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addFaculty();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

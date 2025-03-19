import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // Mock data for registered users
  final List<Map<String, dynamic>> users = [
    {'id': 'U01', 'name': 'John Doe', 'role': 'Admin'},
    {'id': 'U02', 'name': 'Jane Smith', 'role': 'Faculty'},
    {'id': 'U03', 'name': 'Alan Walker', 'role': 'Student'},
    {'id': 'U04', 'name': 'Lucy Grey', 'role': 'Staff'},
  ];

  // To manage selected users
  final Map<String, bool> selectedUsers = {};

  @override
  void initState() {
    super.initState();
    // Initialize selection status for each user
    for (var user in users) {
      selectedUsers[user['id']] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('User Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Center(child: Text('Edit'))),
                Expanded(flex: 1, child: Center(child: Text('Update'))),
                Expanded(flex: 1, child: Center(child: Text('Delete'))),
                Expanded(flex: 1, child: Center(child: Text('View'))),
                Expanded(flex: 1, child: Center(child: Text('Select'))),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(user['id'])),
                      Expanded(flex: 3, child: Text(user['name'])),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editUser(user),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.update, color: Colors.orange),
                          onPressed: () => _updateUser(user),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.green),
                          onPressed: () => _viewUser(user),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Checkbox(
                          value: selectedUsers[user['id']],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedUsers[user['id']] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit User: ${user['name']}')),
    );
  }
  void _updateUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update User: ${user['name']}')),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    setState(() {
      users.removeWhere((u) => u['id'] == user['id']);
      selectedUsers.remove(user['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted User: ${user['name']}')),
    );
  }

  void _viewUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View User: ${user['name']}')),
    );
  }
}

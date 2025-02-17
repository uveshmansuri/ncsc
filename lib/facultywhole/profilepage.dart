import 'package:flutter/material.dart';

class ProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> staff;

  ProfileDetailPage({required this.staff});

  @override
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late TextEditingController addressController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: widget.staff['address'] ?? "");
    phoneController = TextEditingController(text: widget.staff['phone'] ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.lightBlue[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile_placeholder.png"),
            ),
            SizedBox(height: 20),
            _buildInfoCard(Icons.person, widget.staff['name']),
            _buildInfoCard(Icons.email, widget.staff['email']),
            _buildInfoCard(Icons.school, widget.staff['qualification']),
            _buildInfoCard(Icons.work, widget.staff['role']),
            _buildInfoCard(Icons.location_on, widget.staff['address'] ?? "Not Provided"),
            _buildInfoCard(Icons.phone, widget.staff['phone'] ?? "Not Provided"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Address & Phone"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Address", addressController),
              _buildTextField("Phone", phoneController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _saveProfileChanges(),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  void _saveProfileChanges() {
    setState(() {
      widget.staff['address'] = addressController.text;
      widget.staff['phone'] = phoneController.text;
    });
    Navigator.pop(context);
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoleBasedDashboard extends StatefulWidget {
  @override
  _RoleBasedDashboardState createState() => _RoleBasedDashboardState();
}

class _RoleBasedDashboardState extends State<RoleBasedDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseEvent event = await _dbRef.child('users/${user.uid}/role').once();
      setState(() {
        userRole = event.snapshot.value.toString();
      });
    }
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: userRole == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          ListTile(
            title: Text("Circular"),
            onTap: () => navigateToPage(context, CircularPage()),
          ),
          ListTile(
            title: Text("Complaint"),
            onTap: () => navigateToPage(context, ComplaintPage()),
          ),
          if (userRole == "lab_assistant") ...[
            ListTile(
              title: Text("Lab Assistant Page"),
              onTap: () => navigateToPage(context, LabAssistantPage()),
            ),
            ListTile(
              title: Text("Attendance"),
              onTap: () => navigateToPage(context, AttendancePage()),
            ),
            ListTile(
              title: Text("Notes"),
              onTap: () => navigateToPage(context, NotesPage()),
            ),
          ],
          if (userRole == "science_lab_assistant") ...[
            ListTile(
              title: Text("Science Lab Page"),
              onTap: () => navigateToPage(context, ScienceLabPage()),
            ),
            ListTile(
              title: Text("Attendance"),
              onTap: () => navigateToPage(context, AttendancePage()),
            ),
            ListTile(
              title: Text("Material"),
              onTap: () => navigateToPage(context, Materialrequiment()),
            ),
          ],
          if (userRole == "clerk")
            ListTile(
              title: Text("Clerk Page"),
              onTap: () => navigateToPage(context, ClerkPage()),
            ),
          if (userRole == "office_superintendent")
            ListTile(
              title: Text("Office Superintendent Page"),
              onTap: () => navigateToPage(context, OfficeSuperintendentPage()),
            ),
        ],
      ),
    );
  }
}
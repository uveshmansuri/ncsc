import 'dart:convert';
import 'package:NCSC/librarywhole/Library_DashBoard.dart';
import 'package:NCSC/nonteachingdashboard/profilenonteaching.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import '../admin/students.dart';
import '../logout.dart';
import 'circularnonteaching.dart';
import 'clerkpage.dart';
import 'complainnonteaching.dart';
import 'computerlabdashboard.dart';
import 'notesforall.dart';
import 'officesupriender.dart';
import 'labquery.dart';
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
  int _selectedIndex = 0;
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    fetchUserRoles();
    fetchProfileDetails();
  }

  Future<void> fetchUserRoles() async {
    try {
      String key = widget.username.trim().toUpperCase();
      DatabaseEvent event = await _dbRef
          .child('Staff')
          .child('non_teaching')
          .child(key)
          .child('roles')
          .once();
      var rolesData = event.snapshot.value;
      List<String> rolesList = [];
      if (rolesData != null) {
        if (rolesData is List) {
          rolesList =
          List<String>.from(rolesData.where((role) => role != null));
        } else if (rolesData is Map) {
          var sortedKeys = rolesData.keys.toList()
            ..sort();
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

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> fetchProfileDetails() async {
    try {
      String key = widget.username.trim().toUpperCase();
      DatabaseEvent event = await _dbRef
          .child('Staff')
          .child('non_teaching')
          .child(key)
          .once();

      var data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          phoneController.text = data['phone']?.toString() ?? '';
          addressController.text = data['address']?.toString() ?? '';
          qualificationController.text =
              data['qualification']?.toString() ?? '';
          _base64Image = data['profileI']?.toString();
        });
      }
    } catch (e) {
      print("Error fetching profile details: $e");
    }
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
          color: Theme
              .of(context)
              .primaryColor,
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

  Widget buildHomePage() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme
                      .of(context)
                      .primaryColor,
                  child: Text(
                    widget.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                title: Text(
                  "Welcome, ${widget.username}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  userRoles.isNotEmpty
                      ? "Roles: ${userRoles.join(", ")}"
                      : "Roles: Unknown",
                ),
              ),
            ),
            SizedBox(height: 20),

            // Common Dashboard Items for All Roles
            buildDashboardItem(
              title: "Circular",
              icon: Icons.campaign,
              page: StaffCircularsPage(),
            ),
            // buildDashboardItem(
            //   title: "TimeTable",
            //   icon: Icons.calendar_today,
            //   page: complainnonteaching(),
            // ),

            SizedBox(height: 20),

            // Role-Specific Dashboard Items
            if (userRoles.contains("Lab Assistant")) ...[
              buildDashboardItem(
                title: "Lab Query",
                icon: Icons.computer,
                page: FetchComputerLabQueries(),
              ),
              buildDashboardItem(
                title: "Notes",
                icon: Icons.sticky_note_2,
                page: CalendarScreen(username: widget.username),
              ),
            ],

            if (userRoles.contains("Librarian")) ...[
              buildDashboardItem(
                title: "Books",
                icon: Icons.book,
                page: Library_Main(),
              ),
              buildDashboardItem(
                title: "Notes",
                icon: Icons.sticky_note_2,
                page: CalendarScreen(username: widget.username),
              ),
            ],

            if (userRoles.contains("Science Lab Assistant")) ...[
              buildDashboardItem(
                title: "Lab Query",
                icon: Icons.science,
                page: FetchScienceLabQueries(),
              ),
              buildDashboardItem(
                title: "Attendance",
                icon: Icons.account_circle_outlined,
                page: FetchScienceLabQueries(),
              ),
            ],

            if (userRoles.contains("Clerk")) ...[
              buildDashboardItem(
                title: "Documentation Request",
                icon: Icons.assignment_ind,
                page: ClerkRequestPage(),
              ),
              buildDashboardItem(
                title: "Student",
                icon: Icons.person,
                page: Students(),
              ),
            ],
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      buildHomePage(),
      ProfilePage(username: widget.username),  // Added ProfilePage here
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: pages[_selectedIndex], // Accessing the selected page from the list
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
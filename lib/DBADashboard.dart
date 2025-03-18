import 'package:NCSC/admin/students.dart';
import 'package:NCSC/facultywhole/staffmanag.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'admin/Circulars.dart';
import 'admin/Subjects.dart';
import 'fundir/department.dart';
import 'fundir/leave.dart';
import 'fundir/log.dart';
import 'fundir/reco.dart';
import 'fundir/setting.dart';
import 'logout.dart';

class DBA_Dashboard extends StatefulWidget {
  @override
  State<DBA_Dashboard> createState() => _DBA_DashboardState();
}

class _DBA_DashboardState extends State<DBA_Dashboard> {
  int dept_count=0,stud_count=0;
  bool flag=false;
  DatabaseReference ref=FirebaseDatabase.instance.ref();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    count_states();
  }

  void count_states() async{
    try {
      ref.child("department").onValue.listen((event) {
        if (event.snapshot.value != null) {
          setState(() {
            dept_count = event.snapshot.children.length;
          });
        }
      });
      ref.child("Students").onValue.listen((event) {
        if (event.snapshot.value != null) {
          stud_count = event.snapshot.children.length;
          setState(() {
          });
        }
      });
      // DataSnapshot sp=await ref.child("department").get();
      // dept_count=sp.children.length;
      // sp=await ref.child("Students").get();
      // stud_count=sp.children.length;
      // print(stud_count);
    } finally {
      flag=true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !flag,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'DBA Dashboard',
            style: TextStyle(
              fontSize: 25,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue,
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.notifications),
          //     onPressed: () {
          //     },
          //   ),
          //   Padding(
          //     padding: EdgeInsets.only(right: 16),
          //     child: CircleAvatar(
          //       child: Icon(Icons.person),
          //     ),
          //   ),
          // ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'WellCome,\nAD101',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              _buildDrawerItem(
                icon: Icons.account_tree,
                title: 'Department Management',
                page: DepartmentPage(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Staff Management',
                page:StaffManagement(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.subject,
                title: 'Student Management',
                page: Students(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.book,
                title: 'Subjects',
                page: Subjects(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.report,
                title: 'Leave Reports',
                page: LeaveReportsPage(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.announcement,
                title: 'Circulars',
                page: Circulars(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.event_note,
                title: 'Log Entry',
                page: LogEntryPage(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.archive,
                title: 'Records',
                page: RecordsPage(),
                context: context,
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                page: SettingsPage(),
                context: context,
              ),
              TextButton(
                onPressed: (){
                  logout obj=logout();
                  obj.show_dialouge(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout),
                    Text("Logout")
                  ],
                ),
              )
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0), // Center of the gradient
              radius: 1.0, // Spread of the gradient
              colors: [
                //Color(0xFFB2EBF2), // Slightly darker blue (edges)
                Color(0xffffffff),
                Color(0xFFE0F7FA), // Light blue (center)
              ],
              stops: [0.3, 1.0], // Defines the stops for the gradient
            ),
          ),
          child: Column(
            children: [
              Image.asset("assets/images/collageimg.jpg"),
              flag?Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Quick Stats'),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildClickableCard(
                              context: context,
                              title: 'Departments',
                              value: '${dept_count}',
                              page: DepartmentPage(),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildClickableCard(
                              context: context,
                              title: 'Students',
                              value: '${stud_count}',
                              page: Students(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildClickableCard(
                              context: context,
                              title: 'Staff',
                              value: '120',
                              page: StaffManagement(),
                            ),
                          ),
                          SizedBox(width: 8),
                          // Expanded(
                          //   child: _buildClickableCard(
                          //     context: context,
                          //     title: 'Attendance',
                          //     value: '92%',
                          //     page: EnhancedAttendancePage(),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildSectionTitle('Analytics Overview'),
                      SizedBox(height: 10),
                      _buildInfoCard('Attendance Trends', 'Graph Placeholder'),
                      SizedBox(height: 10),
                      _buildInfoCard('Leave Statistics', 'Chart Placeholder'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Notifications & Logs'),
                      SizedBox(height: 10),
                      _buildInfoCard('Recent Logs', 'Activity List Placeholder'),
                    ],
                  ),
                ),
              ):
              Center(
                  child: Lottie.asset("assets/animations/main_loader.json")
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildClickableCard({
    required BuildContext context,
    required String title,
    required String value,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Widget page,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

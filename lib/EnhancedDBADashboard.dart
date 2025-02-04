import 'package:NCSC/try.dart';
import 'package:flutter/material.dart';
import 'facultywhole/staffmanag.dart';
import 'fundir/department.dart';
import 'fundir/circular.dart';
import 'fundir/leave.dart';
import 'fundir/log.dart';
import 'fundir/reco.dart';
import 'fundir/setting.dart';

import 'fundir/stu_man.dart';

class EnhancedDBADashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DBA Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {

            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Navigation Menu',
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
              page: StudentManagementPage(),
              context: context,
            ),
            _buildDrawerItem(
              icon: Icons.check_circle,
              title: 'Attendance',
              page: EnhancedAttendancePage(),
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
              page: CircularsPage(),
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
          ],
        ),
      ),
      body: SingleChildScrollView(
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
                    value: '10',
                    page: DepartmentPage(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildClickableCard(
                    context: context,
                    title: 'Students',
                    value: '850',
                    page: StudentManagementPage(),
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
                Expanded(
                  child: _buildClickableCard(
                    context: context,
                    title: 'Attendance',
                    value: '92%',
                    page: EnhancedAttendancePage(),
                  ),
                ),
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

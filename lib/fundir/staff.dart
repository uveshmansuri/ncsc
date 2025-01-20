import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../funcreate/nonteaching.dart';
import '../funcreate/teaching.dart';

class FacultySeeScreen extends StatefulWidget {
  @override

  _FacultySeeScreenState createState() => _FacultySeeScreenState();
}

class _FacultySeeScreenState extends State<FacultySeeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teaching Staff'),
            Tab(text: 'Non-Teaching Staff'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TeachingStaffList(staffList: []), // Show teaching staff list
          NonTeachingStaffScreen(), // Show non-teaching staff list
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_tabController.index == 0) {
            // Navigate to Add Teaching Staff page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTeachingStaffScreen()),
            );
          } else {
            // Navigate to Add Non-Teaching Staff page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNonTeachingStaffFormScreen()),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

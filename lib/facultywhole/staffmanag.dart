import 'package:NCSC/admin/add_teaching_staff.dart';
import 'package:NCSC/facultywhole/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database
import 'package:NCSC/facultywhole/nonteaching.dart';
import 'package:NCSC/facultywhole/teaching.dart';

class StaffManagement extends StatefulWidget {
  @override
  _StaffManagementState createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _teachingRef = FirebaseDatabase.instance.ref('Staff/faculty');
  final DatabaseReference _nonTeachingRef = FirebaseDatabase.instance.ref('Staff/non_teaching');

  List<Map<String, dynamic>> _teachingStaff = [];
  List<Map<String, dynamic>> _nonTeachingStaff = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Only update UI when tab index has changed
      }
    });

    _fetchTeachingStaff();
    _fetchNonTeachingStaff();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch teaching staff from Firebase
  void _fetchTeachingStaff() async {
    _teachingRef.onValue.listen((event) {
      var data = event.snapshot.value;
      if (data != null && data is Map) { // Ensure data is a Map
        _teachingStaff.clear();
        // Loop through the map to extract data
        data.forEach((key, value) {
          if (value != null && value is Map) { // Ensure value is also a Map
            _teachingStaff.add({
              'name': value['name'] ?? 'Unknown',
              'role': value['post'] ?? 'Unknown',
              'dept':value['department'],
              'id':key ?? 'Unknown'
            });
          }
        });
        setState(() {}); // Refresh UI after data is fetched
      } else {
        print("Error: Data is not a valid map");
      }
    });
  }

  // Fetch non-teaching staff from Firebase
  void _fetchNonTeachingStaff() async {
    _nonTeachingRef.onValue.listen((event) {
      var data = event.snapshot.value;
      if (data != null && data is Map) { // Ensure data is a Map
        _nonTeachingStaff.clear();
        // Loop through the map to extract data
        data.forEach((key, value) {
          if (value != null && value is Map) { // Ensure value is also a Map
            _nonTeachingStaff.add({
              'name': value['name'],
              'role': value['roles'] ?? 'Unknown',
              'id': key ?? 'Unknown'
            });
          }
        });
        setState(() {}); // Refresh UI after data is fetched
      } else {
        print("Error: Data is not a valid map");
      }
    });
  }

  // Navigate to respective add staff screen
  void _navigateToAddStaff() {
    if (_tabController.index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ADD_FACULTY()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddNonTeachingStaff()),
      );
    }
  }

  // Widget for displaying staff data
  Widget _buildStaffList(List<Map<String, dynamic>> staffList,int flag) {
    return ListView.builder(
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        var staff = staffList[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
          child: Card(
            elevation: 10,
            color: Color(0xFFf0f9f0),
            shadowColor: Colors.lightBlueAccent,
            child: ListTile(
              leading: Container(
                  height:50,
                  width:50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blue,
                  ),
                  child: Center(child: Text(
                      "${staff['id']}",
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  ),
                  )
              ),
              title: Text(staff['name'],style: TextStyle(fontSize:15,color: Colors.black,fontWeight: FontWeight.bold)),
              subtitle: flag==1? Text('Post: ${staff['role']}\n'):Text('Post: ${staff['role'][0]}\n'),
              trailing: flag==1? Text("${staff['dept']}",style: TextStyle(fontSize:15,color: Colors.black,fontWeight: FontWeight.bold),):Text(""),
              onTap:(){
                print(staff);
                print(staff["id"]);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileDetailPage(id: staff["id"],flag: flag,)));
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Teaching Staff'),
            Tab(text: 'Non-Teaching Staff'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Teaching Staff Tab
          _buildStaffList(_teachingStaff,1),
          // Non-Teaching Staff Tab
          _buildStaffList(_nonTeachingStaff,0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStaff,
        child: Icon(Icons.add),
        tooltip: _tabController.index == 0 ? 'Add Teaching Staff' : 'Add Non-Teaching Staff',
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

import 'package:NCSC/admin/students.dart';
import 'package:NCSC/facultywhole/staffmanag.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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
  var crr_sem="";
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
      ref.child("Current_Sem").onValue.listen((event){
        setState(() {
          crr_sem=event.snapshot.value.toString();
        });
      });
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
                icon: Icons.announcement,
                title: 'Circulars',
                page: Circulars(),
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
                      Card(
                        elevation: 4,
                        child: GestureDetector(
                          onTap: (){
                            change_sem();
                          },
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Semester",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    crr_sem,
                                    style: TextStyle(fontSize: 20, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildInfoCard('Attendance Trends', 'Graph Placeholder'),
                      SizedBox(height: 20),
                      _buildSectionTitle('Notifications & Logs'),
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

  void change_sem(){
    showDialog(context: context, builder: (context){
      var next_sem=crr_sem=="Odd"?"Even":"Odd";
      return AlertDialog(
        title: Text("Do you want to change current Semester?"),
        content: Text("Current Semester is ${crr_sem}"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("No")),
          TextButton(onPressed: () async{
            await FirebaseDatabase.instance
                .ref("Current_Sem").set("$next_sem")
                .then((_) async{
                  await chenge_details_sem_change(next_sem);
                  Navigator.pop(context);
                })
                .catchError((e){
                  Fluttertoast.showToast(msg: "${e.toString()}");
                });
          }, child: Text("Yes"))
        ],
      );
    });
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

  Future<void> chenge_details_sem_change(String next_sem) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Students");
    DataSnapshot snapshot = await ref.get();

    if (!snapshot.exists) {
      print("No student data found.");
      return;
    }

    String currentYear = DateFormat('yyyy').format(
        DateTime.now()); // Get the current year
    DatabaseReference backupRef = FirebaseDatabase.instance.ref(
        "Backup/$currentYear");

    for (var sp in snapshot.children) {
      String studentId = sp.key ?? "";
      var semValue = sp
          .child("sem")
          .value;

      if (semValue == null) continue;

      int? sem = int.tryParse(semValue.toString());

      if (sem == null) continue;

      if (sem == 6) {
        await backupRef.child(studentId).set(sp.value);
        await ref.child(studentId).remove();
        print("Moved student $studentId to Backup/$currentYear.");
      } else {
        await ref.child(studentId).update({"sem": (sem + 1).toString()});
        print("Updated student $studentId to semester ${sem + 1}.");
      }
    }
  }
}

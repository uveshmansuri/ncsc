import 'package:NCSC/Services/Notification_Service.dart';
import 'package:NCSC/nonteachingdashboard/notesforall.dart';
import 'package:NCSC/student/About_Collage.dart';
import 'package:NCSC/student/About_University.dart';
import 'package:NCSC/student/Assingments.dart';
import 'package:NCSC/student/StudentLibrary.dart';
import 'package:NCSC/student/departmentlist.dart';
import 'package:NCSC/student/feeportal.dart';
import 'package:NCSC/student/internalmarks.dart';
import 'package:NCSC/student/queryraising.dart';
import 'package:NCSC/student/test.dart';
import 'package:NCSC/student/timetable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../Services/Get_Server_key.dart';
import 'Studentprofile.dart';
import 'annoucementstudent.dart';
import 'requests.dart';

class StudentDashboard extends StatefulWidget {
  final String stud_id;
  StudentDashboard({required this.stud_id});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 1;
  late String stud_id;
  late List<Widget> _pages;


  @override
  void initState() {
    super.initState();
    stud_id = widget.stud_id;
    _pages = [
      CalendarScreen(username: stud_id),
      HomeScreen(stud_id: stud_id),
      StudentProfilePage(stud_id: stud_id),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (widget, animation) {
          return FadeTransition(opacity: animation, child: widget);
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.update), label: "Update"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String stud_id;
  HomeScreen({required this.stud_id});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Notification_Service noti_service=Notification_Service();

  List<Map<String, dynamic>> _iconList = [];
  String stud_name = "", dept = "", sem = "", email = "";
  bool flag = false;

  @override
  void initState() {
    super.initState();
    noti_service.get_permission();
    noti_service.setupInteractMsg(context);
    noti_service.firebaseInit(context);
    fetchStudentDetails();
  }

  void fetchStudentDetails() async {
    try {
      //-------------Getting Server Key-------------
      // get_server_key obj=get_server_key();
      // var key=await obj.get_ServerKeyToken();
      // print("$key");
      //---------------------------------------------

      var db = await FirebaseDatabase.instance.ref("Students").child(widget.stud_id).get();
      stud_name = db.child("name").value.toString();
      dept = db.child("dept").value.toString();
      sem = db.child("sem").value.toString();
      email = db.child("email").value.toString();
      _iconList = [
        //{'icon': Icons.help_outline, 'label': 'Query', 'page': QueryPage(stud_id: widget.stud_id)},
        // {
        //   'icon': Icons.access_time,
        //   'label': 'Timetable',
        //   'page': TimetablePage(dept: dept,crr_sem:sem)
        // },
        //{'icon': Icons.announcement, 'label': 'Announcement', 'page': StudentCircularsPage()},
        //{'icon': Icons.school, 'label': 'Department', 'page': DepartmentList()},
        //{'icon': Icons.school, 'label': 'Request', 'page': RequestPage(studentId: widget.stud_id, department: dept, semester: sem)},
        // {
        //   'icon': Icons.grade,
        //   'label': 'Marks',
        //   'page': InternalMarksPage(stud_id: widget.stud_id,dept: dept,sem: sem,)
        // },
        // {
        //   'icon': Icons.assignment_outlined,
        //   'label': 'Assignment',
        //   'page':Assingments(dept: dept, sem: sem)
        // },
        // {
        //   'icon': Icons.assignment,
        //   'label': 'Test',
        //   'page': TestPage(stud_id: widget.stud_id, dept: dept, sem: sem),
        // },
        // {
        //   'icon':Icons.account_balance_sharp,
        //   'label':'Library',
        //   'page':Students_Library(dept: dept),
        // },
        // {
        //   'icon':Icons.business_rounded,
        //   'label':'About College',
        //   'page':About_Collage()
        // },
        // {
        //   'icon':Icons.credit_card,
        //   'label':'Fees Portal',
        //   'page':Fees_Portal()
        // },
        // {
        //   'icon':Icons.account_balance,
        //   'label':'About University',
        //   'page':About_Univercity()
        // },
      ];
      setState(() {
        flag = true;
      });
    } catch (e) {
      //print("Error fetching student details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: flag
          ? Column(
                  children: [
                    Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, ${stud_name}!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Let's get started!",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/student_profile.png'),
                    ),
                  ],
                ),
              ),
            ],
          ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildIconCard(icon: Icons.help_outline, label: 'Query',route: QueryPage(stud_id: widget.stud_id)),
                          _buildIconCard(icon: Icons.access_time, label: "Timetable",route: TimetablePage(dept: dept,crr_sem:sem)),
                          _buildIconCard(icon: Icons.announcement, label: "Announcement",route: StudentCircularsPage()),
                          _buildIconCard(icon: Icons.school, label: "Department",route: DepartmentList()),
                          _buildIconCard(icon: Icons.grade, label: "Internal Marks",route: InternalMarksPage(stud_id: widget.stud_id,dept: dept,sem: sem,)),
                          _buildIconCard(icon: Icons.assignment_outlined, label: "Assignment",route: Assingments(dept: dept, sem: sem)),
                          _buildIconCard(icon: Icons.sync_alt, label: "Requests",route: RequestPage(studentId: widget.stud_id, department: dept, semester: sem)),
                          _buildIconCard(icon: Icons.fact_check, label: "Test",route: TestPage(stud_id: widget.stud_id, dept: dept, sem: sem)),
                          _buildIconCard(icon: Icons.apartment_sharp, label: "About College",route: About_Collage()),
                          _buildIconCard(icon: Icons.credit_card, label: "Fees Portal",route: Fees_Portal()),
                          _buildIconCard(icon: Icons.local_library, label: "Library",route: Students_Library(dept: dept)),
                          _buildIconCard(icon: Icons.account_balance_sharp, label: "About University",route: About_Univercity()),
                        ],
                      ),
                    ),
                    // Flexible(
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(horizontal: 14.0),
                    //     child: GridView.builder(
                    //       physics: BouncingScrollPhysics(),
                    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //         crossAxisCount: 3,
                    //         crossAxisSpacing: 12.0,
                    //         mainAxisSpacing: 12.0,
                    //         childAspectRatio: 1.1,
                    //       ),
                    //       itemCount: _iconList.length,
                    //       itemBuilder: (context, index) {
                    //         return GestureDetector(
                    //           onTap: () => Navigator.push(
                    //             context,
                    //             MaterialPageRoute(builder: (context) => _iconList[index]['page']),
                    //           ),
                    //           child: _buildIconCard(icon: _iconList[index]['icon'], label: _iconList[index]['label']),
                    //         );},
                    //     ),
                    //   ),
                    // ),
                  ],
          )
          :
      Center(child: CircularProgressIndicator()),

      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>assistent()));
      },child: Icon(Icons.smart_toy),),
    );
  }

  Widget _buildIconCard({required IconData icon, required String label, var route}) {
    return InkWell(
      child: Container(
        width: 100,
        height: 100,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>route));
      },
    );
  }
}

class assistent extends StatelessWidget{
  var url="https://cdn.botpress.cloud/webchat/v2.3/shareable.html?configUrl=https://files.bpcontent.cloud/2025/04/05/08/20250405080129-5JH3X9OD.json";
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(url,),
          ),
        ),
      ),
    );
  }
}
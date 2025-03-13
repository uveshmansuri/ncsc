import 'package:NCSC/student/departmentlist.dart';
import 'package:NCSC/student/internalmarks.dart';
import 'package:NCSC/student/queryraising.dart';
import 'package:NCSC/student/syllabus.dart';
import 'package:NCSC/student/test.dart';
import 'package:NCSC/student/timetable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'annoucementstudent.dart';

class StudentDashboard extends StatefulWidget {
  var stud_id;
  StudentDashboard({required this.stud_id});
  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 1;
  var stud_id,stud_name,dept,sem,email;

  List<Widget> _pages=[];

  bool flag=false;

  @override
  void initState() {
    stud_id=widget.stud_id;
    super.initState();
    _pages = [
      Center(child: Text("🔔 Updates", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      HomeScreen(stud_id),
      Center(child: Text("👤 Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
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
  var stud_id;
  HomeScreen(this.stud_id);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _iconList=[];
  var stud_name,dept,sem,email;

  bool flag=false;

  @override
  void initState() {
    super.initState();
    fetch_student_details();
  }

  void fetch_student_details() async{
    try {
      var db=await FirebaseDatabase.instance.ref("Students").child(widget.stud_id).get();
      stud_name=db.child("name").value.toString();
      dept=db.child("dept").value.toString();
      sem=db.child("sem").value.toString();
      email=db.child("email").value.toString();
      flag=true;
      setState(() {
        _iconList = [
          {'icon': Icons.help_outline, 'label': 'Query', 'page': QueryPage()},
          {'icon': Icons.access_time, 'label': 'Timetable', 'page': TimetablePage()},

          {'icon': Icons.access_time, 'label': 'Annocument', 'page': StudentCircularsPage()},
          {'icon': Icons.access_time, 'label': 'departmentlist', 'page': DepartmentList()},

          {'icon': Icons.grade, 'label': 'Marks', 'page': InternalMarksPage()},
          {'icon': Icons.assignment,
            'label': 'Test',
            'page': TestPage(stud_id: widget.stud_id, dept: dept, sem: sem)
          },
        ];
        print(flag);
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return flag==true
        ?
    Column(
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: GridView.builder(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.1,
              ),
              itemCount: _iconList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _iconList[index]['page']),
                  ),
                  child: _buildIconCard(_iconList[index]['icon'], _iconList[index]['label']),
                );
              },
            ),
          ),
        ),
      ],
    )
        :
    Center(child: CircularProgressIndicator(),);
  }

  Widget _buildIconCard(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
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
    );
  }
}


// class DashboardPage extends StatefulWidget {
//   @override
//   _DashboardPageState createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   final List<String> imgList = [
//     'assets/images/collageimg.jpg',
//     'assets/images/collageimg.jpg',
//     'assets/images/collageimg.jpg'
//   ];
//
//   int _currentIndex = 0;
//
//   final List<Map<String, dynamic>> _iconList = [
//     {'icon': Icons.school, 'label': 'Department', 'page': DepartmentPage()},
//    // {'icon': Icons.payment, 'label': 'Fee Portal', 'page': FeePortalPage()},
//     {'icon': Icons.access_time, 'label': 'Timetable', 'page': TimetablePage()},
//     {'icon': Icons.check_circle, 'label': 'Test', 'page': TestPage()},
//     {'icon': Icons.library_books, 'label': 'Syllabus', 'page': SyllabusPage()},
//     {'icon': Icons.grade, 'label': 'Internal Marks', 'page': InternalMarksPage()},
//    // {'icon': Icons.assignment_turned_in, 'label': 'Attendance', 'page': AttendancePage()},
//     {'icon': Icons.assignment_turned_in, 'label': 'Query', 'page': QueryPage()},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF6F7FB),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           'Welcome to NCSC!!!',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: CircleAvatar(
//               backgroundImage: AssetImage('assets/images/faculty_icon.png'),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search',
//                   prefixIcon: Icon(Icons.search),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 child: Column(
//                   children: [
//                     CarouselSlider(
//                       items: imgList.map((item) => Container(
//                         margin: EdgeInsets.all(5.0),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                           child: Image.asset(
//                             item,
//                             fit: BoxFit.cover,
//                             width: 1000.0,
//                           ),
//                         ),
//                       )).toList(),
//                       options: CarouselOptions(
//                         height: 200.0,
//                         autoPlay: true,
//                         enlargeCenterPage: true,
//                         onPageChanged: (index, reason) {
//                           setState(() {
//                             _currentIndex = index;
//                           });
//                         },
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: imgList.asMap().entries.map((entry) {
//                         return GestureDetector(
//                           child: Container(
//                             width: 8.0,
//                             height: 8.0,
//                             margin: EdgeInsets.symmetric(horizontal: 4.0),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 16.0,
//                   mainAxisSpacing: 16.0,
//                   childAspectRatio: 1,
//                 ),
//                 itemCount: _iconList.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => _iconList[index]['page']),
//                       );
//                     },
//                     child: _buildIconButton(_iconList[index]['icon'], _iconList[index]['label']),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIconButton(IconData icon, String label) {
//     return Container(
//       padding: EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 6,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blue.shade800,
//             radius: 25,
//             child: Icon(icon, color: Colors.white),
//           ),
//           SizedBox(height: 8),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'faculty_home.dart';
import 'profile_page.dart';
import 'updates_page.dart';

class FacultyMain extends StatefulWidget {
  final String fid;
  FacultyMain(this.fid);
  @override
  _FacultyMainState createState() => _FacultyMainState();
}
class _FacultyMainState extends State<FacultyMain> {
  int _currentIndex = 1;
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      UpdatesPage(),
      HomePage(widget.fid),
      ProfilePage(widget.fid),
    ];
    return WillPopScope(
      onWillPop: () async{
        if(_currentIndex!=1){
          setState(() {
            _currentIndex=1;
            _pageController.jumpToPage(1);
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(

          index: _currentIndex,
          backgroundColor: Color(0xffd1fbff),
          color: Colors.blue,
          buttonBackgroundColor:  Colors.white,
          height: 50,
          items: <Widget>[
            Tooltip(
              message: 'Updates',
              child: Icon(Icons.update, size: 30, color: _currentIndex == 0 ? Colors.blue : Colors.white),
            ),
            Tooltip(
              message: 'Home',
              child: Icon(Icons.home, size: 30, color: _currentIndex == 1 ? Colors.blue : Colors.white),
            ),
            Tooltip(
              message: 'Profile',
              child: Icon(Icons.person, size: 30, color: _currentIndex == 2 ? Colors.blue : Colors.white),
            ),
            // Icon(Icons.update, size: 25, color: _currentIndex == 0 ? Colors.blue : Colors.white),
            // Icon(Icons.home, size: 25, color: _currentIndex == 1 ? Colors.blue : Colors.white),
            // Icon(Icons.person, size: 25, color: _currentIndex == 2 ? Colors.blue : Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
        ),
      ),
    );
  }
}

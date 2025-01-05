import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'updates_page.dart';

class FacultyMain extends StatefulWidget {
  @override
  _FacultyMainState createState() => _FacultyMainState();
}

class _FacultyMainState extends State<FacultyMain> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    UpdatesPage(),
    HomePage(),
    ProfilePage(),
  ];

  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: Colors.transparent,
        color: Colors.blue,
        buttonBackgroundColor: Colors.white,
        height: 60,
        items: <Widget>[
          Icon(Icons.update, size: 30, color: _currentIndex == 0 ? Colors.blue : Colors.white),
          Icon(Icons.home, size: 30, color: _currentIndex == 1 ? Colors.blue : Colors.white),
          Icon(Icons.person, size: 30, color: _currentIndex == 2 ? Colors.blue : Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
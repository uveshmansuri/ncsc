import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(LibraryDashboardApp());
}

class LibraryDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.brown[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[800],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        drawerTheme: DrawerThemeData(backgroundColor: Colors.brown[100]),
      ),
      home: LibraryDashboard(),
    );
  }
}

class LibraryDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library Dashboard")),
      drawer: LibraryDrawer(),
      body: DashboardContent(),
    );
  }
}

class LibraryDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.brown[700]),
            child: Text("Library Management", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LibraryDashboard())),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text("Books"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BooksPage())),
          ),


          ListTile(
            leading: Icon(Icons.analytics),
            title: Text("Reports"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Students"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StudentsPage())),)
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          DashboardCard(title: "Total Books", count: "1200", icon: Icons.library_books),
          DashboardCard(title: "Issued Books", count: "300", icon: Icons.bookmark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => IssueBookPage()));
          }),
          DashboardCard(title: "Available Books", count: "900", icon: Icons.check_circle),
          DashboardCard(title: "Overdue Books", count: "50", icon: Icons.warning),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback? onTap;

  DashboardCard({required this.title, required this.count, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.brown[100],
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.brown[800]),
              SizedBox(height: 10),
              Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
}

class IssueBookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController studentIdController = TextEditingController();
    Random random = Random();
    DateTime issueDate = DateTime(2024, random.nextInt(12) + 1, random.nextInt(28) + 1);
    DateTime returnDate = issueDate.add(Duration(days: 15));

    return Scaffold(
      appBar: AppBar(title: Text("Issue a Book")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter Student ID", style: TextStyle(fontSize: 18)),
            TextField(controller: studentIdController, decoration: InputDecoration(border: OutlineInputBorder())),
            SizedBox(height: 20),
            Text("Issue Date: ${DateFormat('yyyy-MM-dd').format(issueDate)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Return Date: ${DateFormat('yyyy-MM-dd').format(returnDate)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Book issued to Student ID: ${studentIdController.text}")),
                  );
                },
                child: Text("Issue Book"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class StudentsPage extends StatelessWidget {
  final List<String> students = ["Student 1", "Student 2", "Student 3", "Student 4"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Students List")),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(students[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                IconButton(icon: Icon(Icons.info), onPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BooksPage extends StatelessWidget {
  final List<String> books = ["Book A", "Book B", "Book C", "Book D"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Books List")),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                IconButton(icon: Icon(Icons.info), onPressed: () {}),
              ],
            ),
          );
        },
      ),
    );
  }
}
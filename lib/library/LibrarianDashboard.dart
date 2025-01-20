import 'package:flutter/material.dart';
import 'add_book.dart';
import 'manage_books.dart';
import 'retrieve_books.dart';

class LibrarianDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Librarian Dashboard'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Add Book'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBookScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Manage Books'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageBooksScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Retrieve Books'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RetrieveBooksScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

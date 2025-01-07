import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LibrarianManageBooks extends StatefulWidget {
  @override
  _LibrarianManageBooksState createState() => _LibrarianManageBooksState();
}

class _LibrarianManageBooksState extends State<LibrarianManageBooks> {
  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref("books");
  late DatabaseReference _booksStream;

  @override
  void initState() {
    super.initState();
    _booksStream = _booksRef;
  }

  void _updateBookStatus(String bookId, String status) {
    _booksRef.child(bookId).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Books')),
      body: StreamBuilder(
        stream: _booksStream.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            var data = snapshot.data!.snapshot.value;
            if (data == null) {
              return Center(child: Text('No books available.'));
            }
            List<Widget> bookWidgets = [];
            return ListView(children: bookWidgets);
          }

          return Center(child: Text('Failed to load books.'));
        },
      ),
    );
  }
}

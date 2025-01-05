import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LibrarianAddBook extends StatefulWidget {
  @override
  _LibrarianAddBookState createState() => _LibrarianAddBookState();
}

class _LibrarianAddBookState extends State<LibrarianAddBook> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref("books");

  void _addBook() {
    String title = _titleController.text;
    String author = _authorController.text;
    String department = _departmentController.text;

    if (title.isNotEmpty && author.isNotEmpty && department.isNotEmpty) {
      String bookId = _booksRef.push().key ?? '';
      _booksRef.child(bookId).set({
        'title': title,
        'author': author,
        'department': department,
        'status': 'available'
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book Added Successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Add Book')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Book Title'),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Book Author'),
            ),
            TextField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addBook,
              child: Text('Add Book'),
            ),
          ],
        ),
      ),
    );
  }
}

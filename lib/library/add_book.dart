import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddBookScreen extends StatelessWidget {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final DatabaseReference _booksRef = FirebaseDatabase.instance.ref().child('books');

  void _addBook() {
    String title = _titleController.text;
    String author = _authorController.text;

    if (title.isNotEmpty && author.isNotEmpty) {
      _booksRef.push().set({
        'title': title,
        'author': author,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
      ),
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
              decoration: InputDecoration(labelText: 'Author'),
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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LibrarianDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Librarian Dashboard')),
      body: ListView(
        children: [
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
            title: Text('Approve Book Requests'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApproveRequestsScreen()),
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

// Screen for Managing Books
class ManageBooksScreen extends StatefulWidget {
  @override
  _ManageBooksScreenState createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  final fr_db=FirebaseDatabase.instance.ref();
  final List<Map<String, dynamic>> books = [];
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String author = '';
  String department = '';
  String book_id = '';
  int availableCopies = 0;

  
  void _addBook() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        books.add({
          'title': title,
          'author': author,
          'department': department,
          'availableCopies': availableCopies,
        });
        final fr_db=FirebaseDatabase.instance.ref();
        fr_db.child("books").child(book_id).set(books).then((_){
          print("Added");
        });
      });
      Navigator.pop(context);
    }
  }

  void _openAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Book'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                  onSaved: (value) => title = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Author'),
                  validator: (value) => value!.isEmpty ? 'Enter an author' : null,
                  onSaved: (value) => author = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Department'),
                  validator: (value) => value!.isEmpty ? 'Enter a department' : null,
                  onSaved: (value) => department = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Available Copies'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter available copies' : null,
                  onSaved: (value) => availableCopies = int.parse(value!),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(onPressed: Navigator.of(context).pop, child: Text('Cancel')),
            ElevatedButton(onPressed: _addBook, child: Text('Add')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Books')),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book['title']),
            subtitle: Text('Author: ${book['author']}, Department: ${book['department']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  books.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _openAddBookDialog,
      ),
    );
  }
}

// Screen for Approving Book Requests
class ApproveRequestsScreen extends StatelessWidget {
  final List<Map<String, String>> requests = [
    {'student': 'Alice', 'book': 'Book 1', 'status': 'Pending'},
    {'student': 'Bob', 'book': 'Book 2', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approve Requests')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            title: Text('${request['book']} (Student: ${request['student']})'),
            subtitle: Text('Status: ${request['status']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    requests[index]['status'] = 'Approved';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Approved ${request['book']} for ${request['student']}'),
                    ));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    requests[index]['status'] = 'Rejected';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Rejected ${request['book']} for ${request['student']}'),
                    ));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Screen for Retrieving Books
class RetrieveBooksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> issuedBooks = [
    {'title': 'Book 1', 'student': 'Alice'},
    {'title': 'Book 2', 'student': 'Bob'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Retrieve Books')),
      body: ListView.builder(
        itemCount: issuedBooks.length,
        itemBuilder: (context, index) {
          final book = issuedBooks[index];
          return ListTile(
            title: Text(book['title']),
            subtitle: Text('Issued to: ${book['student']}'),
            trailing: IconButton(
              icon: Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Marked ${book['title']} as returned by ${book['student']}'),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
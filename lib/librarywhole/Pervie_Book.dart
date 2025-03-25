import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Preview extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  Preview(this.books);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<Preview> {
  List<Map<String, dynamic>> editableBooks = [];

  @override
  void initState() {
    super.initState();
    editableBooks = List.from(widget.books);
  }

  void updateBook(int index, String key, dynamic value) {
    setState(() {
      editableBooks[index][key] = value;
    });
  }

  void uploadToFirebase() {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("Books");
    int count=0;
    for (var book in editableBooks) {
      dbRef.child(book["id"]).set({
        "name": book["name"],
        "author": book["author"],
        "copies": book["copies"],
        "dept": book["dept"],
      }).then((_){
        count++;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Total $count Book's Data Uploaded Successfully!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit & Upload Data")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: [
              DataColumn(label: Text("Book ID")),
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Author")),
              DataColumn(label: Text("Copies")),
              DataColumn(label: Text("Dept")),
            ],
            rows: List.generate(editableBooks.length, (index) {
              var book = editableBooks[index];
              return DataRow(cells: [
                DataCell(Text(book["id"])),
                DataCell(TextFormField(
                  initialValue: book["name"],
                  onChanged: (value) => updateBook(index, "name", value),
                )),
                DataCell(TextFormField(
                  initialValue: book["author"],
                  onChanged: (value) => updateBook(index, "author", value),
                )),
                DataCell(TextFormField(
                  initialValue: book["copies"].toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => updateBook(index, "copies", int.tryParse(value) ?? 0),
                )),
                DataCell(TextFormField(
                  initialValue: book["dept"],
                  onChanged: (value) => updateBook(index, "dept", value),
                )),
              ]);
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadToFirebase,
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}
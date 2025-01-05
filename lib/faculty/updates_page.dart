import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdatesPage extends StatefulWidget {
  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final DatabaseReference _updatesRef = FirebaseDatabase.instance.ref("updates");
  List<String> _updatesList = [];

  @override
  void initState() {
    super.initState();
    _updatesRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _updatesList = data.values.map((value) => value.toString()).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Updates Page'),
        backgroundColor: Colors.blue,
      ),
      body: _updatesList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _updatesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.update),
            title: Text(_updatesList[index]),
          );
        },
      ),
    );
  }
}

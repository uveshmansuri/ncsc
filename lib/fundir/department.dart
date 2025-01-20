import 'dart:convert';
import 'package:NCSC/funcreate/create_dep.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DepartmentPage extends StatefulWidget {
  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final dbRef = FirebaseDatabase.instance.ref("department");
  final List<DeptModel> _depts = [];

  @override
  void initState() {
    super.initState();
    _fetchDept();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Departments',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0),
            radius: 1.0,
            colors: [Color(0xffffffff), Color(0xFFE0F7FA)],
            stops: [0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Hero(
              tag: "dept",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _depts.isEmpty
                  ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 5.0,
                ),
              )
                  : ListView.builder(
                itemCount: _depts.length,
                itemBuilder: (context, index) {
                  final dept = _depts[index];
                  return Card(
                    elevation: 8,
                    margin: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: dept.img.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            base64Decode(dept.img),
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                        title: Text(
                          dept.dname,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.blue),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              'ID: ${dept.did}',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(dept),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => create_dept()));
          if (res == true) {
            _depts.clear();
            _fetchDept();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: BottomAppBar(
          color: Colors.blue,
          child: Text(
            '© NARMADA COLLEGE SCIENCE AND COMMERCE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// Fetch department data from Firebase
  void _fetchDept() async {
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      for (DataSnapshot sp in snapshot.children) {
        var did = sp.child("department_id").value.toString();
        var dname = sp.child("department").value.toString();
        var img = sp.child("img").value.toString();
        _depts.add(DeptModel(did, dname, img));
      }
    }
    setState(() {});
  }

  /// Confirm and delete department
  void _confirmDelete(DeptModel dept) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Department'),
        content: Text(
            'Are you sure you want to delete the department "${dept.dname}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _deleteDept(dept.did);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Delete department from Firebase
  void _deleteDept(String id) async {
    await dbRef.child(id).remove().then((_) {
      Fluttertoast.showToast(msg: "Department deleted successfully!");
      _depts.removeWhere((dept) => dept.did == id);
      setState(() {});
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error: $error");
    });
  }
}

class DeptModel {
  String did, dname, img;
  DeptModel(this.did, this.dname, this.img);
}

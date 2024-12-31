import 'dart:convert';
import 'package:NCSC/admin/create_dept.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DepartmentPage extends StatefulWidget {
  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final db_ref=FirebaseDatabase.instance.ref("department");
  final List<dept_model> _depts=[];

  @override
  void initState() {
    super.initState();
    _fetch_dept();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Departments',style:
          TextStyle(
            fontSize: 30,
            color: Colors.white
          ),),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0), // Center of the gradient
            radius: 1.0, // Spread of the gradient
            colors: [
              Color(0xffffffff),
              Color(0xFFE0F7FA), // Light blue (center)// Slightly darker blue (edges)
            ],
            stops: [0.3,1.0], // Defines the stops for the gradient
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10,),
            Hero(
              tag: "dept",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_rounded,size: 40,color: Colors.blue,),
                  SizedBox(width: 30,),
                  Text(
                    'Departments',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _depts.isEmpty
                  ? Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      backgroundColor: Colors.grey,
                      strokeWidth: 5.0,
                    ),
                  ),
                )
                  : ListView.builder(
                itemCount: _depts.length,
                itemBuilder: (context, index) {
                  final dept = _depts[index];
                  return Card(
                    elevation: 10,
                    margin: EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        leading: dept.img.isNotEmpty
                            ? Image.memory(
                          base64Decode(dept.img),
                          width: 75,
                          height: 75,
                          fit: BoxFit.fitHeight,
                        )
                            : Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                        title: Text(dept.dname,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.blue
                            )
                        ),
                        //subtitle: Text('ID: ${dept.did}'),
                        trailing: Text('ID: ${dept.did}'),
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
        onPressed: () async{
           var res=await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>create_dept()));
           if(res==true){
             _depts.clear();
             _fetch_dept();
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
      )
    );
  }

  void _fetch_dept() async{
    final snapshot=await db_ref.get();
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var did=sp.child("department_id").value.toString();
        var dname=sp.child("department").value.toString();
        var img=sp.child("img").value.toString();
        _depts.add(dept_model(did, dname, img));
      }
    }
    setState(() {
    });
  }
}

class dept_model{
  String did,dname,img;
  dept_model(this.did,this.dname,this.img);
}
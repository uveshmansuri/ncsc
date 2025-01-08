import 'dart:convert';
import 'package:NCSC/admin/create_faculty.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class FacultyPage extends StatefulWidget {
  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final db_ref=FirebaseDatabase.instance.ref("Faculties");
  final List<faculty_model> _faculties=[];

  @override
  void initState() {
    super.initState();
    _fetch_faculty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculties',style:
          TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold
          ),
        ),
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
                tag: "faculty",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      child: Image.asset("assets/images/faculty_icon.png",
                        height: 60,
                        width: 60,
                      ),
                    ),
                    SizedBox(width: 15,),
                    Text(
                      'Faculties',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold,color: Colors.blue),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: _faculties.isEmpty
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
                  itemCount: _faculties.length,
                  itemBuilder: (context, index) {
                    final faculty = _faculties[index];
                    return Card(
                      elevation: 10,
                      margin: EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          leading: faculty.img.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: Image.memory(base64Decode(faculty.img),
                              height: 50,
                              width: 50,
                              fit: BoxFit.fill,
                            ),
                          )
                              : Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                          title: Text(faculty.fname,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blue
                              )
                          ),
                          subtitle: Text(faculty.f_faculty),
                          //subtitle: Text('ID: ${faculty.did}'),
                          trailing: Text('Post: ${faculty.post}'),
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
          bool res=await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>create_faculty()));
          if(res){
            _faculties.clear();
            _fetch_faculty();
          }
          //print(res);
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
  void _fetch_faculty() async{
    // print("Fetching....");
    // try {
    //   final database = FirebaseDatabase.instance;
    //   database.ref(".info/connected").onValue.listen((event) {
    //     final connected = event.snapshot.value as bool? ?? false;
    //     if (connected) {
    //       print("Connected to Firebase Realtime Database");
    //     } else {
    //       print("Not connected to Firebase Realtime Database");
    //     }
    //   });
    final snapshot=await db_ref.get();
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var post=sp.child("post").value.toString();
        var name=sp.child("name").value.toString();
        var img=sp.child("img").value.toString();
        var faculty=sp.child("department").value.toString();
        _faculties.add(faculty_model(post, name, img,faculty));
      }
    }
    setState(() {
    });
  }
}

class faculty_model{
  String post,fname,img,f_faculty;
  faculty_model(this.post,this.fname,this.img,this.f_faculty);
}
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Student_Form extends StatefulWidget{
  @override
  State<Student_Form> createState() => _Student_FormState();
}

class _Student_FormState extends State<Student_Form> {
  TextEditingController txt_sid=TextEditingController();

  TextEditingController txt_sname=TextEditingController();

  TextEditingController txt_mail=TextEditingController();

  List<String> dept_lst=[];
  String dept = '';
  String selected_did='';

  List<String> semester_lst = ["1", "2", "3", "4", "5", "6"];
  var selectedSemester="";

  final _formKey = GlobalKey<FormState>();



  @override
  void initState() {
    super.initState();
    _fetch_dept();
  }

  void _fetch_dept() async{
    final db_ref=FirebaseDatabase.instance.ref("department");
    final snapshot=await db_ref.get();
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var dname=sp.child("department").value.toString();
        dept_lst.add(dname);
      }
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Student"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.lightBlueAccent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/student_profile.png",height: 50,width: 50,),
                                  Text("Add Detail",style: TextStyle(fontSize: 30,color: Colors.black,fontWeight: FontWeight.bold),)
                                ],
                              ),
                              SizedBox(height: 20,),
                              TextFormField(
                                controller: txt_sid,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.badge),
                                  labelText: "Enter Student Id",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter student id';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20,),
                              TextFormField(
                                controller: txt_sname,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: "Enter Student Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter student name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20,),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.business_rounded),
                                  labelText: "Select Department",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                items: dept_lst
                                    .map((group) =>
                                    DropdownMenuItem<String>(
                                      value: group,
                                      child: Text(group),
                                    ))
                                    .toList(),
                                onChanged: (value) {
                                  dept = value!;
                                },
                                validator: (value) => value == null ? 'Please select a department' : null,
                              ),
                              SizedBox(height: 20,),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.business_rounded),
                                  labelText: "Select Semester",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                items: semester_lst
                                    .map((group) =>
                                    DropdownMenuItem<String>(
                                      value: group,
                                      child: Text(group),
                                    ))
                                    .toList(),
                                onChanged: (value) {
                                  selectedSemester = value!;
                                },
                                validator: (value) => value == null ? 'Please select a department' : null,
                              ),
                              SizedBox(height: 20,),
                              TextFormField(
                                controller: txt_mail,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  labelText: "Enter Email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20,),
                              ElevatedButton.icon(
                                icon: Icon(Icons.add),
                                label: Text("Add Student"),
                                onPressed: (){
                                  if(_formKey.currentState!.validate()){
                                    add_student();
                                  }
                                },
                              )
                            ]
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
  void add_student() async{
    final db_ref=FirebaseDatabase.instance.ref("Students");
    final sp=await db_ref.child(txt_sid.text.toString()).get();
    if(sp.exists){
      Fluttertoast.showToast(msg: "Student Id is Already Exists");
      return;
    }
    await db_ref.child(txt_sid.text.trim())
        .set({
          "stud_id":txt_sid.text.trim(),
          "name":txt_sname.text.trim(),
          "email":txt_mail.text.trim(),
          "dept":dept,
          "sem":selectedSemester
        })
        .then(
            (_){
              Fluttertoast.showToast(msg: "Student's Detail Added");
              Navigator.pop(context,true);
            })
        .catchError(
            (error){
              Fluttertoast.showToast(msg: error.toString());
            });
  }
}
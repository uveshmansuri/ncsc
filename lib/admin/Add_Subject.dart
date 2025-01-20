import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Add_Subject extends StatefulWidget{
  @override
  State<Add_Subject> createState() => _Add_SubjectState();
}

class _Add_SubjectState extends State<Add_Subject> {

  final sub_id=TextEditingController();
  final sub_name=TextEditingController();
  final txt_semester=TextEditingController();

  List<String> dept_lst=[];
  String dept = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetch_dept();
    super.initState();
  }

  void fetch_dept() async{
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
        title: Text('Add Subjects',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body:Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0,horizontal: 10),
          child: Column(
            children: [
              Form(
                  key:_formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: sub_id,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.numbers_outlined),
                          labelText: "Enter Subject Id",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty ? "Enter Subject ID" : null,
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: sub_name,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.menu_book_rounded),
                          labelText: "Enter Subject Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty ? "Enter Subject Name" : null,
                      ),
                      SizedBox(height: 20,),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.business_rounded),
                          labelText: "Select Department",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                          items: dept_lst.map((group) =>
                              DropdownMenuItem<String>(
                                value: group,
                                child: Text(group),
                              ))
                              .toList(),
                          onChanged: (selected_dept){
                            dept=selected_dept!;
                          },
                        validator: (value) => value == null ? 'Please select a department' : null,
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        controller: txt_semester,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.school_rounded),
                          labelText: "Enter Semester",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                        validator: (value) => value!.trim().isEmpty ? "Enter Semester" : null,
                      ),
                      ElevatedButton(
                          onPressed: (){
                            if(_formKey.currentState!.validate()){
                              add_sub();
                            }
                          },
                          child: Text("Add Subject")
                      )
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  void add_sub() async{
    final db_ref=FirebaseDatabase.instance.ref();
    final sp=await db_ref.child("Subjects").child(sub_id.value.text).get();
    if(sp.exists){
      Fluttertoast.showToast(msg: "Subject Id is exists\nIt's must be unique");
      return;
    }
    await db_ref.child("Subjects")
        .child(sub_id.value.text)
        .set(
        {
          "id":sub_id.value.text,
          "name":sub_name.value.text,
          "dept":dept,
          "sem":txt_semester.value.text
        })
        .then(
            (_){
              Fluttertoast.showToast(msg: "Subject Added");
              Navigator.pop(context,true);
            })
        .catchError(
            (err){
              Fluttertoast.showToast(msg: "${err.toString()}");
            });
  }
}
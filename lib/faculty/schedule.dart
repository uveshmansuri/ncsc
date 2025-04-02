import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'Createschedulepage.dart';

class SchedulePage extends StatefulWidget {
  var dept,fid;
  bool ishod;
  SchedulePage({required this.fid,required this.dept,required this.ishod});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool is_schedule=false;
  var dept_id;

  Map<dynamic, dynamic>? timetable;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetch_schedule();
  }

  void fetch_schedule() async{
    var db=await FirebaseDatabase.instance.ref("department").get();
    for(DataSnapshot sp in db.children){
      if(sp.child("department").value.toString()==widget.dept){
        if(sp.child("timetable").exists){
          final data = sp.value;
          if (data != null && data is Map) {
            setState(() {
              timetable = data;
              dept_id=sp.key;
              _loading = false;
              is_schedule=sp.child("timetable").exists;
            });
          }
        }
        else{
          setState(() {
            timetable = null;
            _loading = false;
          });
        }
        dept_id=sp.key;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: timetable == null?AppBar(
            title:
            Text("Time Table")
        ):null,
        body:
        Center(
          child: _loading
              ? const CircularProgressIndicator()
              : timetable == null
              ? const Text("No timetable available, Add Now!")
              : timetable_preview(timtable_data: jsonEncode(timetable), dept_id: dept_id, dept: widget.dept,is_hod: widget.ishod,),
        ),

        floatingActionButton:
        widget.ishod==true&&is_schedule!=true
            ?
        FloatingActionButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Createschedulepage(department:widget.dept,did:dept_id)),
            );
          },
          child: Icon(Icons.add),
        )
            :
        null
    );
  }
}
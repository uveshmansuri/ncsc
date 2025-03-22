import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  var dept,fid;
  bool ishod;
  SchedulePage({required this.fid,required this.dept,required this.ishod});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool is_schedule=true;

  @override
  void initState() {
    super.initState();
    fetch_schedule();
  }

  void fetch_schedule() async{
    var db=await FirebaseDatabase.instance.ref("department").get();
    for(DataSnapshot sp in db.children){
     if(sp.child("department").value.toString()==widget.dept){
       setState(() {
         is_schedule=sp.child("Schedule").exists;
       });
       break;
     }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Schedule")),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(is_schedule==false)
          Center(
              child:
              Text(
                "Schedule is not avilable",
                style: TextStyle(fontSize: 24)
              ),
          ),
        ],
      ),
      floatingActionButton: widget.ishod==true&&is_schedule==false
          ?
      FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.add),
      )
          :
      null
    );
  }
}
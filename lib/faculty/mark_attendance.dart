import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'attendancetake.dart';

class mark_attend extends StatefulWidget{
  var dept,sem,sub;

  List<students> stud_lst=[];
  List<stud_attent_list> sa_list=[];

  mark_attend(this.dept, this.sem, this.sub, this.stud_lst);

  mark_attend.from_livefeed(this.sub,this.sa_list);

  @override
  State<mark_attend> createState() => _mark_attendState();
}

class _mark_attendState extends State<mark_attend> {
  bool flag=false;
  var _msg="";

  List<stud_attent_list> s_list=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.stud_lst.length>0){
      for(students s in widget.stud_lst){
        s_list.add(stud_attent_list(id:s.stud_id, name:s.stud_name));
        setState(() {});
      }
    }else{
      print("Live feed List:-${widget.sa_list.length}");
      for(stud_attent_list s in widget.sa_list){
        s_list.add(stud_attent_list(id: s.id, name: s.name, isChecked: s.isChecked));
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: flag,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mark Attendance"),
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: s_list.length,
                        itemBuilder: (context,i){
                          return CheckboxListTile(
                            title: Text(s_list[i].name),
                            subtitle: Text(s_list[i].id),
                              value: s_list[i]!.isChecked,
                              onChanged: (bool? val){
                                setState(() {
                                  s_list[i].isChecked=val!;
                                });
                              },
                          );
                        }
                    ),
                  ),
                  ElevatedButton(
                      onPressed: (){
                        save_attend();
                      },
                      child: Text("Save")
                  ),
                ],
              ),
            ),
            if(flag==true)
              Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 5),
                  Text(_msg),
                ],
              ),
              )
          ],
        ),
      ),
    );
  }
  void save_attend() async {
    String crr_date = DateFormat("dd-MM-yyyy-HH").format(DateTime.now());
    setState(() {
      _msg="Saving Attendance";
      flag = true;
    });
    var count=0;
    var db=FirebaseDatabase.instance.ref("Attendance").child(widget.sub).child("$crr_date");
    for(stud_attent_list sl in s_list){
      var status=sl.isChecked?"P":"A";
      await db.child(sl.id).set({"status": status}).then((_){count++;});
    }
    if(count>0){
      setState(() {
        flag=false;
        Navigator.pop(context);
      });
    }
    //   final db_ref=FirebaseDatabase.instance.ref("Attendance")
    //       .child(widget.dept).child(widget.sem)
    //       .child(widget.sub).child(crr_date);
    //   Map<String, String> attendanceData = {};
    //   for(stud_attent_list sl in s_list){
    //     var status=sl.isChecked==true?"P":"A";
    //     attendanceData[sl.id] = status;
    //   }
    //   await db_ref.set(attendanceData).then((_){
    //     Navigator.pop(context);
    //     Fluttertoast.showToast(msg: "Attendance Saved");
    //   }).catchError((e){ Fluttertoast.showToast(msg: "${e.toString()}");});
    // }
  }
}

class stud_attent_list {
  String id;
  String name;
  bool isChecked;
  stud_attent_list({required this.id, required this.name, this.isChecked = false});
}
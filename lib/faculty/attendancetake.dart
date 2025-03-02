import 'package:NCSC/faculty/LiveFeed_Attend.dart';
import 'package:NCSC/faculty/Live_Feed_Web.dart';
import 'package:NCSC/faculty/mark_attendance.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  var dept,sem,sub;
  AttendancePage(this.dept,this.sem,this.sub);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<students> stud_list=[];
  List<stud_attend_pr> attend_pr_list=[];

  int total_class=0;

  @override
  void initState() {
    // TODO: implement initState
    fect_students();
    super.initState();
  }

  void fect_students() async{

    var db_ref=await FirebaseDatabase.instance.ref("Students").get();

    var db_ref2=FirebaseDatabase.instance.ref("Attendance").child(widget.sub);
    var sp2=await db_ref2.get();
    if(sp2.exists)
      total_class=sp2.children.length;

    for(DataSnapshot sp in db_ref.children){
      if(sp.child("dept").value.toString()==widget.dept&&sp.child("sem").value.toString()==widget.sem){
        int class_count=0;
        double pr=0.0;
        if(sp2.exists){
          for(DataSnapshot s in sp2.children){
            for (DataSnapshot s1 in s.children){
              if(s1.key==sp.key && s1.child("status").value.toString()=="P"){
                class_count++;
              }
            }
          }
          pr=(class_count*100)/total_class;
        }

        if(sp.child("encoding").exists){
          List<dynamic> encodings = List<dynamic>.from(sp.child("encoding").value as List);
          //print("Name: ${sp.child("name").value.toString()} ${encodings.length}");
          stud_list.add(students(
              stud_id: sp.key,
              stud_name: sp.child("name").value.toString(),
              encodings: encodings,
              atten_pr:pr
          ));
        }else{
          stud_list.add(students(
              stud_id: sp.key, 
              stud_name: sp.child("name").value.toString(),
              atten_pr:pr
          ));
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: Center(
          child: Column(
            children: [
              Text(
                  "${widget.sub} Attendance Sheet",
                  style: TextStyle(fontSize: 24)
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.lightBlueAccent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Student Id",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                        Text("Student Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                        Text("Attendance Pr(%)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListView.builder(
                        itemCount: stud_list.length,
                        itemBuilder: (context,i){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
                            child: Card(
                              elevation: 3,
                              shadowColor: Colors.lightBlueAccent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        flex:4,
                                        child: Text(stud_list[i].stud_id)
                                    ),
                                    Expanded(
                                        flex:5,
                                        child: Text(stud_list[i].stud_name)
                                    ),
                                    Expanded(
                                        flex:3,
                                        child: Text("${stud_list[i].atten_pr?.toStringAsFixed(2)}%")
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  )
              ),
              Card(
                elevation: 5,
                shadowColor: Colors.lightBlueAccent,
                child: TextButton(
                    onPressed: () async{
                      String crr_date = DateFormat("dd-MM-yyyy-HH-mm").format(DateTime.now());
                      var sp=await FirebaseDatabase.instance.ref("Attendance").child(widget.sub).child(crr_date).get();
                      if(sp.exists){
                        Fluttertoast.showToast(msg: "You can Take Attendance After One Hour");
                      }else{
                        show_dig(crr_date);
                      }
                    },
                    child: Text("Take Attendance")
                ),
              ),
              SizedBox(height: 10,)
            ],
          )
      ),
    );
  }

  void show_dig(String crr_date){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Confirm Session"),
        content: Text("Do you want to take attendance of "
            "\n${widget.dept} Semester:${widget.sem} Subject:${widget.sub}"
            "\nDate:$crr_date"
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
                if(kIsWeb){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context)=>
                              Live_feed_web(widget.dept,widget.sem,widget.sub,stud_list)
                      )
                  );
                }else{
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context)=>
                              Live_Attend(widget.dept,widget.sem,widget.sub,stud_list)
                      )
                  );
                }

              }, child: Text("Auto")),
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        mark_attend(widget.dept, widget.sem, widget.sub,stud_list)
                    ));
              }, child: Text("Manually")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Cancel")),
            ],
          ),
        ],
      );
    });
  }
}

class students{
  var stud_id,stud_name;
  double? atten_pr;
  List<dynamic>? encodings;
  students({required this.stud_id, required this.stud_name, this.encodings,this.atten_pr});
}

class stud_attend_pr{
  var sid,total;
  stud_attend_pr(this.sid,this.total);
}
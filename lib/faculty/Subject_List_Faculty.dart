import 'package:NCSC/faculty/Tests_list.dart';
import 'package:NCSC/faculty/addassignment.dart';
import 'package:NCSC/faculty/attendancetake.dart';
import 'package:NCSC/faculty/internalmarkssend.dart';
import 'package:NCSC/faculty/seeallassignment.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class faculty_sub_lst extends StatefulWidget{
  var fid,flag,dept;
  bool ishod;
  faculty_sub_lst(this.fid,this.flag,this.ishod,this.dept);
  @override
  State<faculty_sub_lst> createState() => _faculty_sub_lstState();
}

class _faculty_sub_lstState extends State<faculty_sub_lst> {
  List<subject> sub_list=[];
  bool is_loading=false;
  @override
  void initState() {
    super.initState();
    print("${widget.fid},${widget.flag},${widget.ishod},${widget.dept}");
    fetch_subjects(widget.fid);
  }

  void fetch_subjects(var fid) async{
    var db=await FirebaseDatabase.instance.ref("Current_Sem").get();
    var crr_sem=db.value.toString();
    var c_sem=[];
    if(crr_sem=="Odd"){
      c_sem=["1","3","5"];
    }else{
      c_sem=["2","4","6"];
    }
    sub_list.clear();
    var db_ref=await FirebaseDatabase.instance.ref("Subjects").get();
    for(DataSnapshot sp in db_ref.children){
      List<dynamic> assing_faculties = [];
      List<dynamic> assing_faculty_name=[];
      if(sp.child("ass_faculties").exists){
        assing_faculties.addAll(sp.child("ass_faculties").value as List<dynamic>);
        for (var fid in assing_faculties){
          var fname=await FirebaseDatabase.instance.ref("Staff/faculty/$fid").child("name").get();
          assing_faculty_name.add(fname.value.toString());
        }
      }
      if(widget.ishod){
        if(sp.child("dept").value.toString()==widget.dept){
          var sub,sid,dept,sem;
          sem=sp.child("sem").value.toString();
          if(c_sem.contains(sem)){
            sub=sp.child("name").value.toString();
            sid=sp.key;
            dept=sp.child("dept").value.toString();
            sub_list.add(subject(sid, sub, fid, dept, sem, assing_faculty_name));
          }
          setState(() {
            is_loading=true;
          });
        }
      }
      else{
        if(assing_faculties.contains(widget.fid)){
          var sub,sid,dept,sem;
          sem=sp.child("sem").value.toString();
          if(c_sem.contains(sem)){
            sub=sp.child("name").value.toString();
            sid=sp.key;
            dept=sp.child("dept").value.toString();
            sub_list.add(subject(sid, sub, fid, dept, sem, assing_faculties));
          }
          setState(() {
            is_loading=true;
          });
        }
      }
    }
    print(is_loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subjects"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0), // Center of the gradient
            radius: 1.0, // Spread of the gradient
            colors: [
              Color(0xFFE0FCFF),
              Color(0xffffffff),
            ],
            stops: [0.3,1.0], // Defines the stops for the gradient
          ),
        ),
        child: is_loading==true?Column(
          children: [
            if(widget.flag==0)
              get_title("Attendance"),
            if(widget.flag==1)
              get_title("Internal Marks"),
            if(widget.flag==2)
              get_title("Assingments"),
            if(widget.flag==3)
              get_title("Tests"),
            Expanded(
              child: ListView.builder(
                  itemCount: sub_list.length,
                  itemBuilder: (context,i){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 7),
                      child: Card(
                        elevation: 10,
                        color: Color(0xFFf0f9f0),
                        shadowColor: Color(0xFFd7ffef),
                        child: ListTile(
                          leading: Text(sub_list[i].sid),
                          title: Text(sub_list[i].sname,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          subtitle: widget.ishod?
                          Text(
                            "Assign Faculties:-\n-${sub_list[i].ass_faculties.join("\n-")}",
                          )
                              :
                          Text("Department:"+sub_list[i].dept),
                          trailing: Text("Semester:"+sub_list[i].sem),
                          onTap: (){
                            if(widget.flag==0) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (context)=>AttendancePage(sub_list[i].dept,sub_list[i].sem,sub_list[i].sname)
                                  )
                              );
                            }
                            if(widget.flag==1){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (context)=>InternalMarksPage(sub_list[i].dept,sub_list[i].sem,sub_list[i].sname)
                                  )
                              );
                            }
                            if (widget.flag == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AssignmentPage(
                                    subjectName: sub_list[i].sname,
                                    dept: sub_list[i].dept,
                                    faculty: widget.fid,
                                    sem: sub_list[i].sem,
                                    ishod: widget.ishod, // ✅ Fix: Pass HOD status
                                  ),
                                ),
                              );
                            }
                            if(widget.flag==3){
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context)=>Test_list(
                                        dept: sub_list[i].dept,
                                        sem: sub_list[i].sem,
                                        sub: sub_list[i].sname,
                                        fid: sub_list[i].fid,
                                      )
                                  )
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }
              ),
            ),
          ],
        )
            :
        Center(
            child: CircularProgressIndicator()
        )
      )
    );
  }
  Widget get_title(var msg){
    return Text("$msg",style: TextStyle(fontSize: 25,color: Color(0xFF0000FF)),);
  }
}

class subject{
  var sid,sname,fid,dept,sem;
  List<dynamic> ass_faculties;
  subject(this.sid,this.sname,this.fid,this.dept,this.sem,this.ass_faculties);
}
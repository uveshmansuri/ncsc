import 'package:NCSC/faculty/addassignment.dart';
import 'package:NCSC/faculty/attendancetake.dart';
import 'package:NCSC/faculty/internalmarkssend.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class faculty_sub_lst extends StatefulWidget{
  var fid,flag;
  faculty_sub_lst(this.fid,this.flag);
  @override
  State<faculty_sub_lst> createState() => _faculty_sub_lstState();
}

class _faculty_sub_lstState extends State<faculty_sub_lst> {
  List<subject> sub_list=[];
  bool flag=false;
  @override
  void initState() {
    fetch_subjects(widget.fid);
    super.initState();
  }
  void fetch_subjects(var fid) async{
    sub_list.clear();
    var db_ref=await FirebaseDatabase.instance.ref("Subjects").get();
    for(DataSnapshot sp in db_ref.children){
      if(sp.child("faculty").value.toString()==widget.fid){
        var sub,sid,dept,sem;
        sub=sp.child("name").value.toString();
        sid=sp.key;
        dept=sp.child("dept").value.toString();
        sem=sp.child("sem").value.toString();
        sub_list.add(subject(sid, sub, fid, dept, sem));
        setState(() {
          flag=true;
        });
      }
    }
    print(flag);
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
        child: Column(
          children: [
            if(widget.flag==0)
              get_title("Attendance"),
            if(widget.flag==1)
              get_title("Internal Marks"),
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
                          subtitle: Text("Department:"+sub_list[i].dept),
                          trailing: Text("Semester:"+sub_list[i].sem),
                          onTap: (){
                            if(widget.flag==0) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (context)=>AttendancePage()
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
                            if(widget.flag==2){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (context)=>AssignmentPage()
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
        ),
      )
    );
  }
  Widget get_title(var msg){
    return Text("$msg",style: TextStyle(fontSize: 25,color: Color(0xFF0000FF)),);
  }
}

class subject{
  var sid,sname,fid,dept,sem;
  subject(this.sid,this.sname,this.fid,this.dept,this.sem);
}
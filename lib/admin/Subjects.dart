import 'package:NCSC/admin/Add_Subject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Subjects extends StatefulWidget{
  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  final db_ref=FirebaseDatabase.instance.ref("Subjects");
  final List<subject_model> sublist=[];

  bool flag=true;
  @override
  void initState() {
    super.initState();
    fetch_subjects();
  }

  void fetch_subjects() async {
    final snap=await db_ref.get();
    if(snap.exists){
      flag=true;
      for(DataSnapshot sp in snap.children){
        String id=sp.child("id").value.toString();
        String name=sp.child("name").value.toString();
        String dept=sp.child("dept").value.toString();
        String sem=sp.child("sem").value.toString();;
        sublist.add(subject_model(id, name, dept, sem));
        setState(() {
        });
      }
    }else{
      flag=false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subjects",
            style: TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold)
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
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            sublist.length==0?
            Center(
                child: Center(
                  child:CircularProgressIndicator(),
                )
            ) :
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: sublist.length,
                      itemBuilder: (context,index){
                        return Card(
                          elevation: 10,
                          color: Color(0xFFf0f9f0),
                          shadowColor: Color(0xFFd7ffef),
                          child: ListTile(
                            leading: Container(
                                height:50,
                                width:50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.blue,
                                ),
                                child: Center(child: Text(
                                  sublist[index].id,
                                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                ),
                                )
                            ),
                            // leading:ClipOval(
                            //   child: Container(
                            //       color: Colors.blue,
                            //       width: 50.0,
                            //       height: 50.0,
                            //       child: Padding(
                            //         padding: const EdgeInsets.all(5),
                            //         child: Center(
                            //             child: Text(
                            //               sublist[index].id,
                            //               style: TextStyle(color: Colors.white),
                            //             )
                            //         ),
                            //       )
                            //   ),
                            // ),
                            title: Text(
                             sublist[index].name,
                             style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.lightBlue),
                            ),
                            subtitle: Text(
                              "Department:${sublist[index].dept}\nSemester:${sublist[index].sem}",
                              style: TextStyle(fontSize: 10,color: Colors.grey,),
                            ),
                            trailing: IconButton(
                                onPressed: ()=>show_alert(index),
                                icon: Icon(Icons.delete_forever_sharp,color: Colors.red,size: 25,)
                            ),
                          ),
                        );
                      }
                  ),
                )
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          bool res=await Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Subject()));
          if(res){
            sublist.clear();
            fetch_subjects();
          }
        },
        child: Icon(Icons.add),
        tooltip: "Add Subject",
      ),
    );
  }
  Future<void> delete_sub(int index) async {
    await db_ref.child(sublist[index].id)
        .remove()
        .then(
            (_){
              sublist.removeAt(index);
              setState(() {});
              Fluttertoast.showToast(msg: "Subject Deleted");
            })
        .catchError(
            (err){
              Fluttertoast.showToast(msg: "Error:${err.toString()}");
            });
  }

  void show_alert(int index){
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text("NCSC"),
        content: Text("Do you Want to delete Subject?"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(ctx);
          }, child: Text("No"),),
          TextButton(onPressed: (){
            delete_sub(index);
            Navigator.pop(ctx);
          }, child: Text("Yes"),),
        ],
      );
    });
  }
}

class subject_model{
  String id,name,dept,sem;
  subject_model(this.id,this.name,this.dept,this.sem);
}
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class InternalMarksPage extends StatefulWidget {
  var dept,sem;
  InternalMarksPage(this.dept,this.sem);
  @override
  State<InternalMarksPage> createState() => _InternalMarksPageState();
}

class _InternalMarksPageState extends State<InternalMarksPage> {
  List<students> stud_list=[];
  List<TextEditingController> ed_list=[];

  @override
  void initState() {
    fetch_students(widget.dept, widget.sem);
    super.initState();
  }

  void fetch_students(var dept,var sem) async{
    var db_ref=await FirebaseDatabase.instance.ref("Students").get();
    for(DataSnapshot sp in db_ref.children){
      if(sp.child("dept").value.toString()==dept&&sp.child("sem").value.toString()==sem){
        stud_list.add(students(sp.key, sp.child("name").value.toString()));
        ed_list.add(TextEditingController());
        setState(() {});
      }
    }
    //print(stud_list.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Internal Marks")),
      body: Column(
        children: [
          Text("Enter Internal Marks"),
          Expanded(
              child: ListView.builder(
                  itemCount: stud_list.length,
                  itemBuilder: (context,i){
                    return ListTile(
                      title: Text(stud_list[i].stud_name,style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                      subtitle: Text(stud_list[i].stud_id),
                      trailing: Container(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: ed_list[i],
                          decoration: InputDecoration(
                            hintText: "Enter Marks"
                          ),
                        ),
                      ),
                    );
                  }
              )
          ),
        ],
      )
    );
  }
}

class students{
  var stud_id,stud_name;
  students(this.stud_id,this.stud_name);
}
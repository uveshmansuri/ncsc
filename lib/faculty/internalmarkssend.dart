import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InternalMarksPage extends StatefulWidget {
  var dept,sem,sub;
  InternalMarksPage(this.dept,this.sem,this.sub);
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
      int? marks=0;
      if(sp.child("dept").value.toString()==dept&&sp.child("sem").value.toString()==sem){
        var db=await FirebaseDatabase.instance.ref("internal_marks/${widget.dept}/${widget.sem}/${sp.key}/${widget.sub}").get();
        //print(db.exists);
        stud_list.add(students(sp.key, sp.child("name").value.toString(),db.value));
        var _ctr=TextEditingController();
        _ctr.text="${db.value??""}";
        ed_list.add(_ctr);
      }
    }setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Internal Marks")),
      body: Column(
        children: [
          Text("Internal Marks"),
          Expanded(
              child: ListView.builder(
                  itemCount: stud_list.length,
                  itemBuilder: (context,i){
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(stud_list[i].stud_id+"\n"+stud_list[i].stud_name),
                            Container(
                              width: 150,
                              child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: ed_list[i],
                                  decoration: InputDecoration(
                                    label: Text("Enter Marks"),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    // return ListTile(
                    //   title: Text(stud_list[i].stud_name,style:TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                    //   subtitle: Text(stud_list[i].stud_id),
                    //   trailing: Container(
                    //     width: 100,
                    //     child: TextField(
                    //       keyboardType: TextInputType.number,
                    //       controller: ed_list[i],
                    //       decoration: InputDecoration(
                    //         label: Text("Enter Marks"),
                    //       ),
                    //     ),
                    //   ),
                    // );
                  }
              )
          ),
          ElevatedButton(onPressed: save_marks, child: Text("Save"))
        ],
      )
    );
  }

  void save_marks(){
    int count=0;
    int done=0;
    for(students stud in stud_list){
      if(ed_list[count].text.trim().length!=0){
        done++;
      }
      count++;
    }
    showDialog(context: context, builder:(context){
      int c=0;
      return AlertDialog(
        title: Text("Confirm Marks"),
        content: Text("${done} Student's marks added out of ${count},\nAre you sure to Save?"),
        actions: [
          ElevatedButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("No")),
          ElevatedButton(onPressed: () async{
            for(students stud in stud_list){
              final marks = ed_list[c].text.trim();
              if(marks.isEmpty) continue;
              await FirebaseDatabase.instance.ref("internal_marks")
                  .child("${widget.dept}")
                  .child("${widget.sem}")
                  .child(stud.stud_id)
                  .update({
                    widget.sub:ed_list[c].text.trim()
                  }).then((_){
                    print("OK");
                  });
              c++;
            }
            if(c>0){
              Fluttertoast.showToast(msg: "Marks Saved");
              Navigator.pop(context);
            }else{
              Navigator.pop(context);
            }
          }, child: Text("Yes"))
        ],
      );
    });
  }
}

class internal_marks_model{
  var dept,sem,stud_id,subject,marks;
  internal_marks_model(this.dept,this.sem,this.stud_id,this.subject,this.marks);
}

class students{
  var stud_id,stud_name,marks;
  students(this.stud_id,this.stud_name,this.marks);
}
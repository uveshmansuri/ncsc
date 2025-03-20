import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class InternalMarksPage extends StatefulWidget {
  var stud_id,dept,sem;
  InternalMarksPage({required this.stud_id,required this.dept,required this.sem});
  @override
  State<InternalMarksPage> createState() => _InternalMarksPageState();
}

class _InternalMarksPageState extends State<InternalMarksPage> {
  List<String> semester_lst = ["Select Semester","1", "2", "3", "4", "5", "6"];
  var selectedSemester="Select Semester";

  List<marks_model> marks_list=[];

  int total_marks=0;

  bool flag=false;
  @override
  void initState() {
    super.initState();
  }

  void fetch_marks() async{
    var db=await FirebaseDatabase.instance.ref("internal_marks/${widget.dept}/${selectedSemester}/${widget.stud_id}").get();
    if(db.exists){
      total_marks=0;
      for(DataSnapshot sp in db.children){
        total_marks+=int.parse(sp.value.toString());
        marks_list.add(marks_model(sub: sp.key, marks: int.parse(sp.value.toString())));
        setState(() {
          flag=true;
        });
      }
    }
    else{
      setState(() {
        flag=false;
      });
      print("Marks Not avilable");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Internal Marks")),
      body: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedSemester,
                    items: semester_lst.map((sem) {
                      return DropdownMenuItem<String>(
                        value: sem,
                        child: Text("$sem"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSemester = value!;
                        if(selectedSemester!="Select Semester"){
                          marks_list.clear();
                          fetch_marks();
                        }
                      });
                    },
                  ),//For SEM Filter
                ],
              ),
              flag==false
                  ?
              Text("Marks is Not Avilable")
                  :
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text("Total Marks:$total_marks"),
                    Card(
                        child: ListTile(
                          title: Text(
                            "Subject",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),
                          ),
                          trailing: Text(
                            "Marks",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: marks_list.length,
                    itemBuilder: (context,i){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 1),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              marks_list[i].sub,
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),
                            ),
                            trailing: Text(
                              marks_list[i].marks.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
      ),
    );
  }
}

class marks_model{
  var sub,marks;
  marks_model({required this.sub,required this.marks});
}

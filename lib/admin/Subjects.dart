import 'package:NCSC/admin/Add_Subject.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Subjects extends StatefulWidget{
  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  final db_ref=FirebaseDatabase.instance.ref("Subjects");

  List<String> dept_lst=[];
  String dept = 'All';
  String selectedDept = 'All';
  List<String> semester_lst = ["All", "1", "2", "3", "4", "5", "6"];
  var selectedSemester="All";

  late List<subject_model> sublist=[];
  final List<subject_model> temp_sublist=[];

  final Map<String, String> idToName = {
    'F1': 'Alice',
    'F2': 'Bob',
    'F3': 'Charlie',
  };

  bool flag=false;

  @override
  void initState() {
    flag=false;
    super.initState();
    _fetch_dept();
    fetch_subjects();
  }

  void _fetch_dept() async{
    final db_ref=FirebaseDatabase.instance.ref("department");
    final snapshot=await db_ref.get();
    dept_lst.insert(0, "All");
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var dname=sp.child("department").value.toString();
        dept_lst.add(dname);
      }
    }
    setState(() {
    });
  }

  void fetch_subjects() async {
    sublist.clear();
    temp_sublist.clear();
    final snap=await db_ref.get();
    if(snap.exists){
      flag=true;
      for(DataSnapshot sp in snap.children){
        String id=sp.child("id").value.toString();
        String name=sp.child("name").value.toString();
        String dept=sp.child("dept").value.toString();
        String sem=sp.child("sem").value.toString();
        String facultyid=sp.child("faculty").value.toString();
        sublist.add(subject_model(id, name, dept, sem,facultyid));
        temp_sublist.add(subject_model(id, name, dept, sem,facultyid));
        setState(() {
          flag=true;
        });
      }
    }else{
      flag=false;
    }
  }

  void applyFilters() {
    List<subject_model> filteredList = temp_sublist;
    //print(selectedDept);
    if (selectedDept != "All") {
      filteredList = filteredList.where((s) => s.dept == selectedDept).toList();
    }

    if (selectedSemester != "All") {
      filteredList = filteredList.where((s) => s.sem == selectedSemester).toList();
    }

    setState(() {
      sublist = filteredList;
    });
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
        child: flag
            ? Column(
          children: [
            Row(
              children: [
                SizedBox(width: 30,),
                Text("Select Department"),
                SizedBox(width: 30,),
                DropdownButton<String>(
                  value: dept,
                  hint: Text("Select Department"),
                  items: dept_lst
                      .map((group) =>
                      DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      dept = value!;
                      selectedDept=dept;
                      applyFilters();
                      // if(dept=="All"){
                      // //   stud_list.clear();
                      // //   stud_list.addAll(temp_stud_list);
                      // //   setState(() {
                      // //     count=stud_list.length;
                      // //   });
                      //   applyFilters();
                      // }else{
                      //   //int index = dept_lst.indexOf(value!);
                      //   applyFilters();
                      // }
                    });
                  },
                ),//For DEPT Filter
              ],
            ),
            Row(
              children: [
                SizedBox(width: 30,),
                Text("Select Semester"),
                SizedBox(width: 40,),
                DropdownButton<String>(
                  value: selectedSemester,
                  items: semester_lst.map((sem) {
                    return DropdownMenuItem<String>(
                      value: sem,
                      child: Text(sem),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSemester = value!;
                      applyFilters();
                    });
                  },
                ),//For SEM Filter
              ],
            ),
            sublist.isEmpty
                ?
            Center(child: Text("No Subject found"))
                :
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: sublist.length,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Card(
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
                              // onTap: ()=>_showIdDialog(context),
                              onTap: () async{
                                var res=await Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=>assing_faculty(
                                        sublist[index].id,sublist[index].name,dept_lst,sublist[index].fid)
                                    )
                                );
                                if(res==true){
                                  fetch_subjects();
                                }
                              },
                            ),
                          ),
                        );
                      }
                  ),
                )
            ),
          ],
        )
            :
            Center(child: CircularProgressIndicator(),)
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

  void _showIdDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    List<String> suggestions = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Using StatefulBuilder to update the UI within the dialog.
        return StatefulBuilder(
          builder: (context, setState) {
            void updateSuggestions(String input) {
              suggestions = idToName.entries
                  .where((entry) => entry.key.startsWith(input))
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .toList();
              if(suggestions.length==0)
                suggestions.add("Invalid Faculty ID");
              setState(() {});
            }
            return AlertDialog(
              title: const Text('Enter ID'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                    ),
                    onChanged: (value) {
                      // Update the suggestion based on the entered ID.
                      setState(() {
                        updateSuggestions(value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      for (var suggestion in suggestions) Text(suggestion,),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    // You can perform any action with _controller.text here.
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class subject_model{
  String id,name,dept,sem,fid;
  subject_model(this.id,this.name,this.dept,this.sem,this.fid);
}

class assing_faculty extends StatefulWidget{
  var sub_id,subject_name,fid;
  List<String> dept_lst=[];
  assing_faculty(this.sub_id,this.subject_name,this.dept_lst,this.fid);
  @override
  State<assing_faculty> createState() => _assing_facultyState();
}

class faculty{
  var fid,fname,dept;
  faculty(this.fid,this.fname,this.dept);
}

class _assing_facultyState extends State<assing_faculty> {
  List<faculty> faculty_list=[];
  List<faculty> temp_faculty_list=[];
  List<String> dept_lst=[];

  String dept = 'All';
  String selectedDept = 'All';

  var facultyname="";

  @override
  void initState() {
    super.initState();
    dept_lst.addAll(widget.dept_lst);
    print("${widget.fid}");
    fetch_fcaulty();
  }

  void applyFilters() {
    List<faculty> filteredList = temp_faculty_list;
    //print(selectedDept);
    if (selectedDept != "All") {
      filteredList = filteredList.where((s) => s.dept == selectedDept).toList();
    }
    setState(() {
      faculty_list = filteredList;
    });
  }

  void fetch_fcaulty() async{
    var db_ref=await FirebaseDatabase.instance.ref("Staff/faculty").get();
    for(DataSnapshot sp in db_ref.children){
      faculty_list.add(faculty(sp.key, sp.child("name").value.toString(),sp.child("department").value.toString()));
      if(sp.key==widget.fid){
        facultyname=sp.child("name").value.toString();
      }
    }
    setState(() {
      temp_faculty_list.addAll(faculty_list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 30,),
                Text("Select Department"),
                SizedBox(width: 30,),
                DropdownButton<String>(
                  value: dept,
                  hint: Text("Select Department"),
                  items: dept_lst
                      .map((group) =>
                      DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      dept = value!;
                      selectedDept=dept;
                      applyFilters();
                    });
                  },
                ),//For DEPT Filter
              ],
            ),
            Text(
              "Assing Faculty to Subject ${widget.subject_name}",
              style: TextStyle(fontSize: 20),
            ),
            facultyname.length==0?Text("Faculty Not Assinged Yest"):Text(facultyname),
            Expanded(child: ListView.builder(
              itemCount: faculty_list.length,
              itemBuilder: (context,index){
                return ListTile(
                  leading: Text("${faculty_list[index].fid}"),
                  title: Text("${faculty_list[index].fname}"),
                  subtitle: Text("${faculty_list[index].dept}"),
                  trailing: IconButton(onPressed: ()=>assing_faculty(faculty_list[index].fid), icon: facultyname.length==0?Icon(Icons.assignment_turned_in_outlined):Icon(Icons.change_circle)),
                );
              },),
            )
          ],
        ),
      ),
    );
  }

  void assing_faculty(var fid) async{
    await FirebaseDatabase.instance
        .ref("Subjects/${widget.sub_id}")
        .update({"faculty":fid})
        .then(
            (_){
              Fluttertoast.showToast(msg: "Faculty Assinged Succsesfully");
              Navigator.pop(context,true);
            })
        .catchError(
            (err){
              Fluttertoast.showToast(msg: "Failed to Assinged Faculty:${err}");
            });
  }
}
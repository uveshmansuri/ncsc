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
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context)=>assing_faulty(
                                            sublist[index].id, sublist[index].name, dept_lst)
                                    )
                                );
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
}

class subject_model{
  String id,name,dept,sem,fid;
  subject_model(this.id,this.name,this.dept,this.sem,this.fid);
}

class faculty{
  var fid,dept,name;
  faculty(this.fid,this.name,this.dept);
}

class assing_faulty extends StatefulWidget{
  var sub_id,subject_name;
  List<String> dept_lst=[];
  assing_faulty(this.sub_id,this.subject_name,this.dept_lst);

  @override
  State<assing_faulty> createState() => _assing_faultyState();
}

class _assing_faultyState extends State<assing_faulty> {
  List<faculty> faculty_list = [];
  List<faculty> temp_faculty_list = [];

  List<String> dept_lst = [];

  List<dynamic> assing_faculties = [];
  List<faculty> ass_faculty_list = [];

  String dept = 'All';
  String selectedDept = 'All';

  bool flag = false;

  @override
  void initState() {
    super.initState();
    dept_lst.addAll(widget.dept_lst);
    fetch_ass_faculty();
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

  void fetch_ass_faculty() async {
    var db_rf = FirebaseDatabase.instance.ref(
        "Subjects/${widget.sub_id}/ass_faculties");
    var sp = await db_rf.get();
    if (sp.exists) {
      assing_faculties.addAll(sp.value as List<dynamic>);
    }
  }

  void fetch_fcaulty() async {
    var db_ref = await FirebaseDatabase.instance.ref("Staff/faculty").get();
    for (DataSnapshot sp in db_ref.children) {
      if (assing_faculties.contains(sp.key)) {
        ass_faculty_list.add(faculty(sp.key, sp
            .child("name")
            .value
            .toString(), sp
            .child("department")
            .value
            .toString()));
      } else {
        faculty_list.add(faculty(sp.key, sp
            .child("name")
            .value
            .toString(), sp
            .child("department")
            .value
            .toString()));
      }
    }
    setState(() {
      temp_faculty_list.addAll(faculty_list);
      flag = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Faculty"),
      ),
      body: Center(
          child: flag == true
              ?
          Column(
            children: [
              Text("Assign Faculty to ${widget.subject_name}",
                style: TextStyle(fontSize: 25),),
              Text("Assigned Faculties"),
              get_itm(ass_faculty_list, true),
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
                        selectedDept = dept;
                        applyFilters();
                      });
                    },
                  ), //For DEPT Filter
                ],
              ),
              SizedBox(height: 10,),
              Text("Faculties"),
              get_itm(faculty_list, false)
            ],
          )
              :
          CircularProgressIndicator()
      ),
    );
  }

  Widget get_itm(List<faculty> faculty_lst, bool is_assign) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: faculty_lst.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          child: ListTile(
            leading: Text("${faculty_lst[index].fid}"),
            title: Text("${faculty_lst[index].name}"),
            subtitle: Text("Department:${faculty_lst[index].dept}"),
            trailing: IconButton(
                icon: Icon(is_assign ? Icons.remove_circle : Icons.assignment_turned_in_rounded),
                onPressed: () {
                  show_confirm(
                    widget.subject_name,
                    faculty_lst[index].name,
                    faculty_lst[index].fid,
                    index,
                    is_assign,
                  );
                }
            ),
          ),
        );
      },);
  }

  void show_confirm(var sub, var faculty, var fid, int index, bool is_assing) {
    showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: Text("Confirm"),
        content: is_assing
            ?
        Text("Do you want to remove $faculty from $sub?")
            :
        Text("Do you want to assign $sub to $faculty?"),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(ctx);
          }, child: Text("No"),),
          TextButton(onPressed: () {
            is_assing? remove(fid, index) : assign(fid, index);
            Navigator.pop(ctx);
          }, child: Text("Yes"),),
        ],
      );
    });
  }

  void assign(var fid, int index) async {
    var db_rf = FirebaseDatabase.instance.ref(
        "Subjects/${widget.sub_id}/ass_faculties");
    assing_faculties.add(fid);
    await db_rf.set(assing_faculties).then((_) {
      Fluttertoast.showToast(msg: "Assigned!!!");
    });
    setState(() {
      ass_faculty_list.add(faculty(
          faculty_list[index].fid, faculty_list[index].name,
          faculty_list[index].dept));
      faculty_list.removeAt(index);
    });
  }

  void remove(var fid, int index) async {
    var db_rf = FirebaseDatabase.instance.ref(
        "Subjects/${widget.sub_id}/ass_faculties");

    assing_faculties.remove(fid);

    await db_rf.set(assing_faculties).then((_) {
      Fluttertoast.showToast(msg: "Removed!!!");
    });

    setState(() {
      faculty_list.add(faculty(
          ass_faculty_list[index].fid, ass_faculty_list[index].name,
          ass_faculty_list[index].dept));
      ass_faculty_list.removeAt(index);
    });
  }
}
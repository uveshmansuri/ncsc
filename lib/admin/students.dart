import 'dart:io';
import 'package:NCSC/admin/Student_Detail_Form.dart';
import 'package:NCSC/admin/Student_Details_AD.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class Students extends StatefulWidget{
  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  TextEditingController searchController = TextEditingController();

  List<String> dept_lst=[];
  String dept = 'All';
  String selectedDept="All";
  List<String> semester_lst = ["All", "1", "2", "3", "4", "5", "6"];
  var selectedSemester="All";


  List<Student_Model> stud_list=[];
  List<Student_Model> temp_stud_list=[];

  bool get_data_flag=false;

  String? imageUrl;

  @override
  void initState() {
    get_data_flag=false;
    super.initState();
    _fetch_dept();
    fetch_students();
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

  void fetch_students() async{
    DatabaseReference db_ref=FirebaseDatabase.instance.ref("Students");
    var snap=await db_ref.get();
    stud_list.clear();
    temp_stud_list.clear();
    for(DataSnapshot sp in snap.children){
      var stud_id=sp.child("stud_id").value.toString();
      var name=sp.child("name").value.toString();
      var email=sp.child("email").value.toString();
      var dept=sp.child("dept").value.toString();
      var sem=sp.child("sem").value.toString();
      if(sp.child("url").value!=null){
        var url=sp.child("url").value.toString();
        stud_list.add(Student_Model(stud_id: stud_id, name: name, dept: dept, email: email, semester: sem,url: url));
        temp_stud_list.add(Student_Model(stud_id: stud_id, name:  name, dept: dept, email: email, semester: sem, url:url));
      }else{
        stud_list.add(Student_Model(stud_id: stud_id, name: name, dept: dept, email: email, semester: sem));
        temp_stud_list.add(Student_Model(stud_id: stud_id, name:  name, dept: dept, email: email, semester: sem));
      }
    }
    setState(() {
      get_data_flag=true;
    });
  }

  Future<void> pickAndReadCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null) {
      List<Student_Model> students = [];
      // if (Platform.isAndroid || Platform.isIOS) {
      //   // Read file for Android/iOS
      //   File file = File(result.files.single.path!);
      //   String content = await file.readAsString();
      //   students = parseCSV(content);
      // } else {
      //   var fileBytes = result.files.single.bytes;
      //   String content = String.fromCharCodes(fileBytes!);
      //   students = parseCSV(content);
      // }
      var fileBytes = result.files.single.bytes;
      String content = String.fromCharCodes(fileBytes!);
      students = parseCSV(content);
      var res=await Navigator.push(context, MaterialPageRoute(builder: (context)=>preview_data(students,dept_lst)));
      if(res){
        selectedSemester="All";
        dept = 'All';
        searchController.clear();
        fetch_students();
      }
    }
  }

  Future<void> PickandRead_EXCEL() async{
    List<Student_Model> students = [];
    FilePickerResult? res=await FilePicker.platform.pickFiles(
      type: FileType.custom,allowedExtensions: ['xls','xlsx'],
      withData: true,
    );
    if(res!=null){
      var bytes=await res.files.single.bytes;
      String content = String.fromCharCodes(bytes!);
      students=parseCSV(content);
      var res1=await Navigator.push(context, MaterialPageRoute(builder: (context)=>preview_data(students,dept_lst)));
      if(res1){
        selectedSemester="All";
        dept = 'All';
        searchController.clear();
        fetch_students();
      }
    }
  }

  List<Student_Model> parseCSV(String csvString) {
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
    return csvTable.skip(1).map((row) {
      return Student_Model(
        stud_id:row[0].toString(),
        name: row[1].toString(),
        dept: row[2].toString(),
        email: row[3].toString(),
        semester: row[4].toString()
      );
    }).toList();
  }


  void show_alert_msg(int flag){
    showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        title: Text("Instruction of Students Details file"),
        content: Text("Data Must be in Given manner\ni)Student Id\nii) Student Name\niii) Department\niv)Email\nv)Semester"),
        actions: [
          TextButton(
            onPressed: (){
              flag==0?pickAndReadCSV():PickandRead_EXCEL();
              Navigator.pop(context);
            },
            child: Text(
              "Procede",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // void apply_filter(String did){
  //   count=0;
  //   print("main list ${stud_list.length}");
  //   stud_list.clear();
  //   print("main list after ${stud_list.length}");
  //   print("tem list ${temp_stud_list.length}");
  //   for(Student_Model student in temp_stud_list){
  //     if(student.dept==did){
  //       count++;
  //       stud_list.add(student);
  //     }
  //   }
  //   print("count ${count}");
  //   get_data_flag=true;
  //   print("OK");
  //   setState(() {});
  // }
  //
  // void filterSearch(String query) {
  //   setState(() {
  //     stud_list = query.isEmpty
  //         ? temp_stud_list
  //         : temp_stud_list
  //         .where((student) =>
  //     student.name.toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //   });
  // }

  void applyFilters() {
    List<Student_Model> filteredList = temp_stud_list;
    // print(selectedDept);
    // print(dept);
    if (dept != "All") {
      filteredList = filteredList.where((s) => s.dept == dept).toList();
    }

    if (selectedSemester != "All") {
      filteredList = filteredList.where((s) => s.semester == selectedSemester).toList();
    }

    String query = searchController.text.toLowerCase();
    //print(query);
    if (query.isNotEmpty) {
      filteredList = filteredList.where((s) => s.name.toLowerCase().contains(query)).toList();
    }

    setState(() {
      stud_list = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students"),
      ),
      body: AbsorbPointer(
        absorbing: !get_data_flag,
        child: Stack(
          children: [
            Center(
              child:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) => applyFilters(),
                      decoration: InputDecoration(
                        labelText: "Search Students",
                        prefixIcon: Icon(Icons.person_search_sharp),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            applyFilters();
                            },
                        )
                            : null,
                        border: OutlineInputBorder(),
                      ),
                    ),
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
                    Expanded(
                      child: stud_list.isEmpty
                          ?
                      Center(child: Text("No students found"))
                          :
                      ListView.builder(
                        itemCount: stud_list.length,
                        itemBuilder: (context,index){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: Card(
                              elevation: 5,
                              shadowColor: Colors.lightBlueAccent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(stud_list[index].stud_id,overflow: TextOverflow.ellipsis,),
                                          Text(stud_list[index].name,overflow: TextOverflow.ellipsis,),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Department:"+stud_list[index].dept,overflow: TextOverflow.ellipsis,),
                                          Text("Semester:"+stud_list[index].semester,overflow: TextOverflow.ellipsis,),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(onPressed: (){
                                        Navigator.push(context,
                                          MaterialPageRoute(
                                            builder: (context)=>Stud_AD(
                                              stud_id: stud_list[index].stud_id,
                                              sname: stud_list[index].name,
                                              email: stud_list[index].email,
                                              dept: stud_list[index].dept,
                                              sem: stud_list[index].semester,
                                              url: stud_list[index].url,
                                              availableDepts: dept_lst,
                                            ),
                                          ),
                                        );
                                      }, icon: Icon(Icons.remove_red_eye)
                                      ),
                                    ),
                                    // Row(
                                    //   children: [
                                    //     IconButton(onPressed: (){
                                    //       Navigator.push(context,
                                    //           MaterialPageRoute(
                                    //               builder: (context)=>Stud_AD(
                                    //                   stud_id: stud_list[index].stud_id,
                                    //                   sname: stud_list[index].name,
                                    //                   email: stud_list[index].email,
                                    //                   dept: stud_list[index].dept,
                                    //                   sem: stud_list[index].semester,
                                    //                   url: stud_list[index].url
                                    //               )
                                    //           )
                                    //       );
                                    //       }, icon: Icon(Icons.remove_red_eye)
                                    //     ),
                                    //     // IconButton(
                                    //     //     onPressed: ()=>pick_img(index),
                                    //     //     icon: Icon(Icons.add_a_photo)
                                    //     // ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ),
            if(get_data_flag==false)
              Center(child: CircularProgressIndicator())
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close, // FAB icon animation
        backgroundColor: Colors.blue,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(Icons.upload_file),
            label: "Upload CSV",
            onTap: ()=>show_alert_msg(0),
          ),
          SpeedDialChild(
            child: Icon(Icons.upload_file_rounded,),
            label: "Upload Excel",
            onTap: ()=>show_alert_msg(1),
          ),
          SpeedDialChild(
            child: Icon(Icons.person_add_sharp,),
            label: "Add Student",
            onTap: () async {
              var res=await Navigator.push(context, MaterialPageRoute(builder: (context)=>Student_Form()));
              print(res);
              if(res){
                selectedSemester="All";
                dept='All';
                searchController.clear();
                fetch_students();
              }
            },
          ),
        ],
      ),
    );
  }

  void pick_img(int i) async{
    File? _image;
    final ImagePicker _picker = ImagePicker();
    var stud_id=stud_list[i].stud_id;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    if (_image == null) return;
    try{
      print("Uplading...");
      setState(() {
        get_data_flag=false;
      });
      var fileName="students_images/img${stud_id}.png";
      print(fileName);
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask=storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseDatabase.instance.ref("Students/${stud_id}").update({
        "url":downloadUrl
      });
      setState(() {
        stud_list[i].url=downloadUrl;
        Fluttertoast.showToast(msg: "Image Uploaded");
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }finally{
      setState(() {
        get_data_flag=true;
      });
    }
  }
}

class Student_Model{
  String stud_id,name,email,dept,semester;
  String? url;
  Student_Model(
      {required this.stud_id,
        required this.name,
        required this.dept,
        required this.email,
        required this.semester,
        this.url
      });
}

class preview_data extends StatefulWidget{
  List<Student_Model> student_list;
  List<String> availableDepts;
  preview_data(this.student_list,this.availableDepts);
  @override
  State<preview_data> createState() => _preview_dataState();
}

class _preview_dataState extends State<preview_data> {
  // Email validation RegExp
  final RegExp emailRegex =
  RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  bool upload_flag=false;

  @override
  Widget build(BuildContext context) {
    final List<Student_Model> stud_list=widget.student_list;
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Preview"),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: upload_flag,
            child: Center(
              child: ListView.builder(
                itemCount: stud_list.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Card(
                      child: ListTile(
                        leading: Text(stud_list[index].stud_id,softWrap: true,),
                        title: Text(stud_list[index].name,softWrap: true,),
                        subtitle: Text("Email:"+stud_list[index].email,softWrap: true,),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Dept:" +
                                stud_list[index].dept +
                                "\nSemester:" +
                                stud_list[index].semester),
                            IconButton(onPressed: (){
                              showEditDialog(stud_list[index], index);
                            }, icon: Icon(Icons.edit))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if(upload_flag==true)
            Center(
                child: Transform.scale(
                    scale: 2.5,
                    child:Lottie.asset("assets/animations/upload_anim_2.json")
                )
            ),
        ],
      ),
      floatingActionButton: AbsorbPointer(
        absorbing: upload_flag,
        child: FloatingActionButton.extended(
          onPressed: upload_data,
          label: Row(
            children: [
              Text("Upload Data"),
              Icon(Icons.upload)
            ],
          ),
          tooltip: "Upload Data",
        ),
      ),
    );
  }

  // Edit Dialog to update student fields with validations
  void showEditDialog(Student_Model student, int index) {
    final _formKey = GlobalKey<FormState>();
    String stud_id = student.stud_id;
    String name = student.name;
    String email = student.email;
    String dept = student.dept;
    String semester = student.semester;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Student"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Student ID is displayed but set as read-only
                  TextFormField(
                    initialValue: stud_id,
                    decoration: InputDecoration(labelText: "Student ID"),
                    readOnly: true,
                  ),
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: "Name"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                    onChanged: (value) => name = value,
                  ),
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!emailRegex.hasMatch(value.trim())) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                    onChanged: (value) => email = value,
                  ),
                  DropdownButtonFormField(
                    value: dept,
                    decoration: InputDecoration(labelText: "Department"),
                    items: widget.availableDepts.map((deptItem) {
                      return DropdownMenuItem(
                        value: deptItem,
                        child: Text(deptItem),
                      );
                    }).toList(),
                    onChanged: (value) {
                      dept = value.toString();
                    },
                    validator: (value) {
                      if (value == null ||
                          value.toString().trim().isEmpty ||
                          !widget.availableDepts.contains(value)||
                          value=="All"
                      ) {
                        return "Select a valid department";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: semester,
                    decoration: InputDecoration(labelText: "Semester"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Semester is required";
                      }
                      return null;
                    },
                    onChanged: (value) => semester = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Update the student data in the list
                  setState(() {
                    widget.student_list[index] = Student_Model(
                      stud_id: stud_id.trim(),
                      name: name.trim(),
                      email: email.trim(),
                      dept: dept.trim(),
                      semester: semester.trim(),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void upload_data() async{
    bool flag=true;
    upload_flag=true;

    for (Student_Model student in widget.student_list) {
      if (student.stud_id.trim().isEmpty ||
          student.name.trim().isEmpty ||
          student.email.trim().isEmpty ||
          student.dept.trim().isEmpty ||
          student.semester.trim().isEmpty) {
        Fluttertoast.showToast(
            msg: "All fields are required for student: ${student.stud_id}:${student.name}");
        return;
      }
      if (!emailRegex.hasMatch(student.email.trim())) {
        Fluttertoast.showToast(
            msg: "Invalid email for student: ${student.name}");
        return;
      }
      if (!widget.availableDepts.contains(student.dept)) {
        Fluttertoast.showToast(
            msg: "Invalid department for student: ${student.name}");
        return;
      }
    }
    setState(() {});
    DatabaseReference db_ref=FirebaseDatabase.instance.ref();
    for (Student_Model student in widget.student_list){
      await db_ref.child("Students").child(student.stud_id).set(
        {
          "stud_id":student.stud_id,
          "name":student.name,
          "email":student.email,
          "dept":student.dept,
          "sem":student.semester
        }
      ).then(
                    (_){
                    })
                .catchError(
                    (Err){
                      flag=false;
                      Fluttertoast.showToast(msg: Err.toString());
                    });
      if(flag==false){
        break;
      }
    }
    if(flag){
      Fluttertoast.showToast(msg: "Data Uploaded Succsessfully");
      Navigator.pop(context,true);
    }
  //   await db_ref.child("Students").set(widget.student_list)
  //       .then(
  //           (_){
  //             Fluttertoast.showToast(msg: "Data Uploaded Succsessfully");
  //             Navigator.pop(context,true);
  //           })
  //       .catchError(
  //           (Err){
  //             Fluttertoast.showToast(msg: Err.toString());
  //           });
  }
}
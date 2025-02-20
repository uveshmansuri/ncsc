import 'dart:io';
import 'package:NCSC/admin/Student_Detail_Form.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      stud_list.add(Student_Model(stud_id, name, dept, email, sem));
      temp_stud_list.add(Student_Model(stud_id, name, dept, email, sem));
    }
    setState(() {
      get_data_flag=true;
    });
  }

  Future<void> pickAndReadCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      List<Student_Model> students = [];
      if (Platform.isAndroid || Platform.isIOS) {
        // Read file for Android/iOS
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        students = parseCSV(content);
      } else {
        // Read file for Web
        var fileBytes = result.files.single.bytes;
        String content = String.fromCharCodes(fileBytes!);
        students = parseCSV(content);
      }
      var res=await Navigator.push(context, MaterialPageRoute(builder: (context)=>preview_data(students)));
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
      type: FileType.custom,allowedExtensions: ['xls','xlsx']
    );
    if(res!=null){
      File file=File(res.files.single.path!);
      var bytes=await file.readAsBytes();
      String content = String.fromCharCodes(bytes!);
      students=parseCSV(content);
      var res1=await Navigator.push(context, MaterialPageRoute(builder: (context)=>preview_data(students)));
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
        row[0].toString(), // stud_id
        row[1].toString(), // name
        row[2].toString(), // dept
        row[3].toString(), // email
        row[4].toString(), // semester
      );
    }).toList();
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
      body: Center(
        child: get_data_flag
            ?
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(360),
                              child: imageUrl==null ? Image.asset("assets/images/student_profile.png",
                                height: 50,
                                width: 50,
                                fit: BoxFit.fill,
                              ):Image.network(imageUrl!)
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          stud_list[index].stud_id + "\n" +
                                          stud_list[index].name + "\n"
                                          "Dept: " + stud_list[index].dept + "\n"
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Column(
                            //   children: [
                            //     Text(stud_list[index].stud_id),
                            //     Text(stud_list[index].name),
                            //     Text(stud_list[index].email),
                            //     Text("Dept ID:"+stud_list[index].dept),
                            //     Text("Semester:"+stud_list[index].semester),
                            //   ],
                            // ),
                            Row(
                              children: [
                                IconButton(onPressed: (){}, icon: Icon(Icons.remove_red_eye)),
                                IconButton(onPressed: _uploadImage, icon: Icon(Icons.add_a_photo)),
                              ],
                            ),
                          ],
                        ),
                        // child: ListTile(
                        //   leading: Text(stud_list[index].stud_id),
                        //   title: Text(stud_list[index].name),
                        //   subtitle: Text(stud_list[index].email),
                        //   trailing: Text("Dept ID:-"+stud_list[index].dept+"\nSemester:"+stud_list[index].semester),
                        // ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
            :
        CircularProgressIndicator()
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
            onTap: pickAndReadCSV
          ),
          SpeedDialChild(
            child: Icon(Icons.upload_file_rounded,),
            label: "Upload Excel",
            onTap: PickandRead_EXCEL,
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
  Future<void> _uploadImage() async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    FirebaseDatabase _database = FirebaseDatabase.instance;
    String imageUrl = ''; // URL of the uploaded image

    // Open a dialog to choose between camera or gallery
    final ImagePicker _picker = ImagePicker();
    XFile? imageFile;

    imageFile = await _picker.pickImage(source: ImageSource.gallery); // Or change to ImageSource.camera

    if (imageFile == null) return;

    File file = File(imageFile.path);

    if (imageFile == null) return;

    try {
      // Create a reference to Firebase Storage
      Reference storageRef = _storage.ref().child("student_images/${DateTime.now().millisecondsSinceEpoch}.jpg");

      // Upload the image
      UploadTask uploadTask = storageRef.putFile(file);

      // Get the image URL after upload
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store the URL in Firebase Realtime Database
      String studentId = 'your_student_id'; // Use the student's ID here
      await _database.ref('students/$studentId').update({
        'profile_image': downloadUrl,
      });

      setState(() {
        imageUrl = downloadUrl; // Update the image URL
      });

      // Display a success message or perform other actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image!')),
      );
    }
  }
}

class Student_Model{
  String stud_id,name,email,dept,semester;
  Student_Model(this.stud_id,this.name,this.dept,this.email,this.semester);
}

class preview_data extends StatefulWidget{
  List<Student_Model> student_list;
  preview_data(this.student_list);
  @override
  State<preview_data> createState() => _preview_dataState();
}

class _preview_dataState extends State<preview_data> {
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
                        leading: Text(stud_list[index].stud_id),
                        title: Text(stud_list[index].name),
                        subtitle: Text(stud_list[index].email),
                        trailing: Text("Dept ID:-" +
                            stud_list[index].dept +
                            "\nSemester:" +
                            stud_list[index].semester),
                        // trailing: IconButton(onPressed: (){
                        //   setState(() {
                        //     stud_list.removeAt(index);
                        //   });
                        // },icon: Icon(Icons.delete_forever_rounded,color: Colors.red,),)
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
  void upload_data() async{
    bool flag=true;
    upload_flag=true;
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
import 'dart:convert';
import 'dart:io';
import 'package:NCSC/admin/students.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Stud_AD extends StatefulWidget{
  var stud_id,sname,dept,sem,email;
  String? url;
  List<String> availableDepts;
  Stud_AD({required this.stud_id,required this.sname,required this.email,required this.dept,required this.sem,this.url,required this.availableDepts});

  @override
  State<Stud_AD> createState() => _Stud_ADState();
}

class _Stud_ADState extends State<Stud_AD> {
  bool is_uploading=false;
  String _response="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student's Detail"),
        actions: [
          IconButton(
            onPressed: (){
              show_delete_student(
                Student_Model(
                  stud_id: widget.stud_id,
                  name: widget.sname,
                  dept: widget.dept,
                  email: widget.email,
                  semester: widget.sem,
                ),
              );
            },
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0), // Center of the gradient
                radius: 1.0, // Spread of the gradient
                colors: [
                  Color(0xFFE0F7FA),
                  Color(0xffd1fbff),
                ],
                stops: [0.3,1.0],
              )
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            child: Material(
                              elevation: 15,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(360),
                                side: BorderSide(
                                  color: Colors.cyan, // Border color
                                  width: 2,// Border width
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(360),
                                  child:
                                  (widget.url != null && widget.url!.isNotEmpty)
                                      ?
                                  Image.network(
                                    widget.url!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                      :
                                  Image.asset(
                                      "assets/images/student_profile.png",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                              )
                            ),
                            onTap: (){
                              print("Tap");
                            },
                          ),
                          GestureDetector(
                            onTap: ()=>_pickImage(),
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 20,
                              child: Icon(Icons.edit, color: Colors.white, size: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                    build_item(widget.stud_id, Icons.badge_outlined),
                    build_item(widget.sname, Icons.account_circle),
                    build_item(widget.email, Icons.email_rounded),
                    build_item(widget.dept, Icons.apartment_sharp),
                    build_item("Semester:"+widget.sem, Icons.school_outlined),
                  ],
                ),
              ),
              if(is_uploading==true)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // Dim background
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "$_response",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showEditDialog(Student_Model(
            stud_id: widget.stud_id,
            name: widget.sname,
            dept: widget.dept,
            email: widget.email,
            semester: widget.sem,
          ),);
        },
        child: Icon(Icons.edit),
        tooltip: "Edit Details",
      ),
    );
  }

  Widget build_item(String value,IconData ic){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      child: Card(
        elevation: 10,
        shadowColor: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9,vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(ic,color: Colors.cyan,size: 30,),
              SizedBox(width: 10,),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(value,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void pick_img() async{
    File? _image;
    final ImagePicker _picker = ImagePicker();
    var stud_id=widget.stud_id;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    if (_image == null) return;
    try{
      //print("Uplading...");
      setState(() {
        //get_data_flag=false;
      });
      var fileName="students_images/img${stud_id}.png";
      //print(fileName);
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask=storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseDatabase.instance.ref("Students/${stud_id}").update({
        "url":downloadUrl
      });
      setState(() {
        widget.url=downloadUrl;
        Fluttertoast.showToast(msg: "Image Uploaded");
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }finally{
      setState(() {
        //get_data_flag=true;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadImage(await image.readAsBytes());
    }
    // if (kIsWeb) {
    //   // Web Image Picker
    //   final image = await ImagePickerWeb.getImageAsBytes();
    //   if (image != null) {
    //     setState(() {
    //       _imageBytes = image;
    //     });
    //     await _uploadImage(image);
    //   }
    // } else {
    //
    // }
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    setState(() {
      is_uploading=true;
      _response = "Preparing...";
    });
    print("p..");
    var uri = Uri.parse('http://127.0.0.1:8000/encode');
    List<dynamic>? _faceEncodings;
    print("Starting....");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'face.png'));
    print("Preparing.....");
    try {
      setState(() {
        _response="  Encodings......";
      });
      print("Getting Encodings......");
      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      var decodedData = jsonDecode(responseData);
        if(response.statusCode == 200){
          _faceEncodings = decodedData['encodings'];
          print("Len:${_faceEncodings?.length}");

          if(_faceEncodings?.length==null){
            setState(() {
             is_uploading=false;
            });
            Fluttertoast.showToast(msg: "Uploading Failed\n${decodedData['message']}");
            return;
          }
          if(_faceEncodings!.length>1){
            setState(() {
              is_uploading=false;
            });
            Fluttertoast.showToast(msg: "Uploading Failed\nMultiple Faces Detected");
            return;
          }

          var fileName="students_images/img${widget.stud_id}.png";

          setState(() {
            _response="Uploading Image and Face Encodings......";
          });

          Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask=storageRef.putData(imageBytes!);

          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          await FirebaseDatabase.instance.ref("Students")
              .child(widget.stud_id)
              .update({
                "url":downloadUrl,
                "encoding": _faceEncodings?[0]
              }).then((_){
                setState(() {
                  widget.url=downloadUrl;
                });
                _response ="Task Completed";
                Fluttertoast.showToast(msg: "Image Successfully Uploaded with Encodings");
              }).catchError((err){
                _response =err.toString();
              });
        }
        else{
          setState(() {
            is_uploading=false;
            _response ="Error: ${decodedData['message']}";
          });
          Fluttertoast.showToast(msg: "Error: ${decodedData['message']}");
        }
    } catch (e) {
      setState(() {
        is_uploading=false;
        print(e.toString());
        _response = "Failed to connect to server";
      });
      Fluttertoast.showToast(msg: "Failed to connect to server");
    }finally{
      setState(() {
        is_uploading=false;
        //_response="Image Successfully Uploaded with Encodings";
        //Fluttertoast.showToast(msg: "Image Successfully Uploaded with Encodings");
      });
    }
  }

  void showEditDialog(Student_Model student) {
    final _formKey = GlobalKey<FormState>();
    String stud_id = student.stud_id;
    String name = student.name;
    String email = student.email;
    String dept = student.dept;
    String semester = student.semester;

    final RegExp emailRegex =
    RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

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
                        return "Enter a valid email";
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
              onPressed: () async{
                if (_formKey.currentState!.validate()) {
                  // Update the student data in the list
                  await FirebaseDatabase.instance
                      .ref("Students/$stud_id")
                      .update({
                    "name":name,
                    "dept":dept,
                    "email":email,
                    "sem":semester,
                  }).then((_){
                    Fluttertoast.showToast(msg: "Students Details Updated");
                    setState(() {
                      widget.stud_id = stud_id.trim();
                      widget.sname = name.trim();
                      widget.dept = dept;
                      widget.email = email;
                      widget.sem = semester;
                    });
                  }).catchError((err){
                    Fluttertoast.showToast(msg: err.toString());
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

  void show_delete_student(Student_Model obj){
    showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        title: Text(
          "Confirm Delete Student",
          style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Student Id:${obj.stud_id}\n"
              "Name:${obj.name}\n"
              "Email:${obj.email}\n"
              "Department:${obj.dept}\n"
              "Semester:${obj.semester}\n"
              "Are you Sure to Delete?",
          style: TextStyle(color: Colors.black87,fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () async{
              try {
                if(widget.url!=null){
                  final Reference storageRef = FirebaseStorage.instance.refFromURL(widget.url!);
                  await storageRef.delete().
                  then((_) async{
                    await FirebaseDatabase.instance.ref("Users/${widget.stud_id}").remove();
                    await FirebaseDatabase.instance
                        .ref("Students/${widget.stud_id}").remove()
                        .then((_){
                          Fluttertoast.showToast(msg: "Students Details Deleted");
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }).catchError((err){
                          Fluttertoast.showToast(msg: "${err.toString()}");
                          Navigator.pop(context);
                        });
                  }).catchError((err){
                    Fluttertoast.showToast(msg: "${err.toString()}");
                    Navigator.pop(context);
                  });
                  return;
                }
                await FirebaseDatabase.instance
                    .ref("Students/${widget.stud_id}").remove()
                    .then((_) async{
                      await FirebaseDatabase.instance.ref("Users/${widget.stud_id}").remove();
                      Fluttertoast.showToast(msg: "Students Details Deleted");
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }).catchError((err){
                      Fluttertoast.showToast(msg: "${err.toString()}");
                      Navigator.pop(context);
                    });
              } catch (e) {
                print('Error deleting file: $e');
              }
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red,fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.blue,fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
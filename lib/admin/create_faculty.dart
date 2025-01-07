import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class create_faculty extends StatefulWidget{
  @override
  State<create_faculty> createState() => _create_facultyState();
}

class _create_facultyState extends State<create_faculty> {
  File? _imageFile;
  final _img_picker = ImagePicker();
  var img_encode;

  TextEditingController txt_fid=TextEditingController();

  TextEditingController txt_fname=TextEditingController();

  TextEditingController txt_fq=TextEditingController();

  TextEditingController txt_mail=TextEditingController();

  List<String> dept_lst=[];
  String dept = '';

  String? faculty_role; // Variable to store selected value

  final _formKey = GlobalKey<FormState>();

  final db_ref=FirebaseDatabase.instance.ref("department");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetch_dept();
  }

  void _fetch_dept() async{
    final snapshot=await db_ref.get();
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var dname=sp.child("department").value.toString();
        dept_lst.add(dname);
      }
    }
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Faculty',style:
        TextStyle(
          fontSize: 20,
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0), // Center of the gradient
            radius: 1.0, // Spread of the gradient
            colors: [
              Color(0xFFE0F7FA), // Light blue (center)// Slightly darker blue (edges)
              Color(0xffffffff),
            ],
            stops: [0.3,1.0], // Defines the stops for the gradient
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 5,),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key:_formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          child: img_encode==null?CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                              child:Icon(Icons.add_a_photo,
                                      size: 40, color: Colors.blue)
                          ):
                          ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: Image.memory(base64Decode(img_encode),
                              height: 150,
                              width: 150,
                              fit: BoxFit.fill,
                            ),
                          ),
                          onTap: (){
                            _pickImage();
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: txt_fid,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.numbers),
                            labelText: "Enter Faculty Id",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter faculty id';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: txt_fname,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: "Enter Faculty Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter faculty name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: txt_fq,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.history_edu),
                            labelText: "Enter Qualification",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(width: 1.5),
                            ),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter faculty's qualification";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.business_rounded),
                            labelText: "Select Department",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(width: 1.5),
                            ),
                          ),
                          items: dept_lst
                              .map((group) =>
                              DropdownMenuItem<String>(
                                value: group,
                                child: Text(group),
                              ))
                              .toList(),
                          onChanged: (value) {
                            dept = value!;
                          },
                          validator: (value) => value == null ? 'Please select a department' : null,
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: txt_mail,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: "Enter Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20,),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all()
                          ),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.design_services),
                                  SizedBox(width: 20,),
                                  Text('Select Faculty Role',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 20,color: Color(0xff707070)),
                                  ),
                                ],
                              ),
                              RadioListTile<String>(
                                title: Text('Head of Department'),
                                value: 'HOD',
                                groupValue: faculty_role,
                                onChanged: (value) => setState(() {
                                  faculty_role = value;
                                }),
                              ),
                              RadioListTile<String>(
                                title: Text('Assistant Profesor'),
                                value: 'Ass..Pro..',
                                groupValue: faculty_role,
                                onChanged: (value) => setState(() {
                                  faculty_role = value;
                                }),
                              ),
                              RadioListTile<String>(
                                title: Text('Teaching Assistant'),
                                value: 'T.A.',
                                groupValue: faculty_role,
                                onChanged: (value) => setState(() {
                                  faculty_role = value;
                                }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()){
                    _create_faculty();
                  }
                },
                child: Text("Add Faculty")
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _img_picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      String base64Image = base64Encode(await _imageFile!.readAsBytes());
      img_encode=base64Image;
    }
  }

  void _create_faculty() async{
    final db_ref=await FirebaseDatabase.instance.ref();
    if(faculty_role==null){
    Fluttertoast.showToast(msg: "Select Role of Faculty");
    }
    else if(img_encode==null){
      Fluttertoast.showToast(msg: "Upload image of Faculty");
    }else{
      showFacultyDialog(context);
    }
  }

  void showFacultyDialog(BuildContext context){
    String faculty_id=txt_fid.text.toString();
    String faculty_name=txt_fname.text.toString();
    String faculty_qualification=txt_fq.text.toString();
    String faculty_email=txt_mail.text.toString();
    String faculty_dept=dept;
    String faculty_descnation=faculty_role.toString();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.person_add_alt_1),
                SizedBox(width: 5,),
                Text("Details Preview"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(360),
                  child: Image.memory(base64Decode(img_encode),
                    height: 50,
                    width: 50,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 5,),
                Text("ID(User Id) ${faculty_id}"),
                SizedBox(height: 5,),
                Text("Name ${faculty_name}"),
                SizedBox(height: 5,),
                Text("Qualifications\n ${faculty_qualification}"),
                SizedBox(height: 5,),
                Text("Email ${faculty_email}"),
                SizedBox(height: 5,),
                Text("Department ${faculty_dept}"),
                SizedBox(height: 5,),
                Text("Post ${faculty_descnation}"),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child:Text("Edit")
              ),
              TextButton(
                  onPressed: () {
                    add_to_firebase();
                  },
                  child:Text("Add")
              )
            ],
          );
        }
    );
  }

  void add_to_firebase() async{
    final db_ref2=await FirebaseDatabase.instance.ref();
    DataSnapshot sp=await db_ref2.child("Faculties").child(txt_fid.text.toString()).get();
    if(sp.exists){
      Fluttertoast.showToast(msg: "FacultyID is already exists");
      return;
    }
    db_ref2.child("Faculties").child(txt_fid.text.toString()).set({
      "faculty_id": txt_fid.text.toString(),
      "name": txt_fname.text.toString(),
      "qualification": txt_fq.text.toString(),
      "email": txt_mail.text.toString(),
      "department": dept,
      "post": faculty_role,
      "img":img_encode
    }).then((_){
      Fluttertoast.showToast(msg: "Faculty added");
      Navigator.pop(context);
      Navigator.pop(context, true);
    }).catchError((error){
      Fluttertoast.showToast(msg: "Error:$error");
      Navigator.pop(context);
    });
  }
  // bool show_alert_msg(){
  //   int flag=0;
  //   showDialog(context: context,
  //     builder: (BuildContext context)=>
  //         AlertDialog(
  //           icon: Image.asset('assets/images/logo1.png',width: 80,height: 80,),
  //           title: Text("Alert"),
  //           content: Text("Are you sure create faculty account without image of faculty"),
  //           actions: [
  //             TextButton(onPressed:
  //                 () {
  //               flag=1;
  //               Navigator.of(context).pop();
  //             },
  //                 child: Text("No")
  //             ),
  //             TextButton(onPressed: (){
  //               flag=0;
  //               Navigator.of(context).pop();
  //             },
  //               child: Text("Yes"),
  //             ),
  //           ],
  //         ),
  //   );
  //   return flag==0;
  // }
}
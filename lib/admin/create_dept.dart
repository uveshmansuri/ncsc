import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class create_dept extends StatefulWidget{
  @override
  State<create_dept> createState() => _create_deptState();
}

class _create_deptState extends State<create_dept> {
  File? _imageFile;
  final _img_picker = ImagePicker();
  var img_encode;

  TextEditingController dept_idtextcontrol=TextEditingController();
  TextEditingController dept_name_textcontrol=TextEditingController();
  //TextEditingController dept_desc_textcontrol=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Departments',style:
        TextStyle(
            fontSize: 30,
            color: Colors.white
        ),),
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
              Color(0xFFE0F7FA), // Light blue (center)// Slightly darker blue (edges)
              Color(0xffffffff),
            ],
            stops: [0.3,1.0], // Defines the stops for the gradient
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle,size: 40,color: Colors.blue,),
                    SizedBox(width: 30,),
                    Text("Add Department",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blue
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: dept_idtextcontrol,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.numbers),
                    labelText: "Enter Department Id",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: dept_name_textcontrol,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.business_rounded),
                    labelText: "Enter Department Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:_pickImage,
                      child: Text('Select Image for Department'),
                    ),
                    if (img_encode == null)
                      Text("Select Image")
                    else
                      Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                          ),
                          child: Image.memory(
                            base64Decode(img_encode),
                            fit: BoxFit.scaleDown,
                          ),
                          // child: Container(
                          //   width: 100.0,
                          //   height: 100.0,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     image: DecorationImage(
                          //       image: MemoryImage(base64Decode(img_encode),),
                          //       fit: BoxFit.cover, // Ensures the image fills the circle
                          //     ),
                          //   ),
                          // ),
                          // //CircleAvatar(
                          // //   radius: 50,
                          // //   backgroundImage: MemoryImage(
                          // //     base64Decode(img_encode),
                          // //   ),
                          // // )
                      )
                  ],
                ),
                SizedBox(height: 30,),
                ElevatedButton(
                    onPressed: add_dept,
                    child:Text("Add Department")
                )
              ],
            ),
          ),
        ),
      )
        ,bottomNavigationBar: SizedBox(
      height: 40,
      child: BottomAppBar(
        color: Colors.blue,
        child: Text(
          '© NARMADA COLLEGE SCIENCE AND COMMERCE',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    )
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

  void add_dept() async{
    final db_ref=await FirebaseDatabase.instance.ref();
    if(dept_idtextcontrol.text.toString().trim().isEmpty||dept_name_textcontrol.text.toString().trim().isEmpty||img_encode.toString().isEmpty){
      Fluttertoast.showToast(msg: "Please Provide all Details");
      return;
    }else{
      DataSnapshot sp= await db_ref.child("department").child(dept_idtextcontrol.text.toString()).get();
      if(sp.exists){
        Fluttertoast.showToast(msg: "Department id is Already Exists!!!");
        return;
      }
      db_ref.child("department").child(dept_idtextcontrol.text.toString())
          .set(
          {
            "department_id":dept_idtextcontrol.text.toString(),
            "department":dept_name_textcontrol.text.toString(),
            "img":img_encode
          })
          .then((_){
        Fluttertoast.showToast(msg: "Department Added Sucsessfuly!!!");
        Navigator.pop(context,true);
      })
          .catchError((error){
        Fluttertoast.showToast(msg: "Error:$error");
      });
    }
  }
}
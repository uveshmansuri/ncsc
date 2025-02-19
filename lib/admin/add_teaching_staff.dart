import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ADD_FACULTY extends StatefulWidget{
  @override
  State<ADD_FACULTY> createState() => _ADD_FACULTYSTATE();
}

class _ADD_FACULTYSTATE extends State<ADD_FACULTY> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();

  final db_ref = FirebaseDatabase.instance.ref();

  String? selectedRoles; // Stores selected roles

  List<String> dept_lst=[];
  String dept = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final snapshot=await db_ref.child("department").get();
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
        title: Text("Add Faculty"),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFf0f9f0),
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
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.badge),
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
                          controller: _nameController,
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
                          controller: _qualificationController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.school),
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
                          controller: _emailController,
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
                                groupValue: selectedRoles,
                                onChanged: (value) => setState(() {
                                  selectedRoles = value;
                                }),
                              ),
                              RadioListTile<String>(
                                title: Text('Assistant Profesor'),
                                value: 'Ass..Pro..',
                                groupValue: selectedRoles,
                                onChanged: (value) => setState(() {
                                  selectedRoles = value;
                                }),
                              ),
                              RadioListTile<String>(
                                title: Text('Teaching Assistant'),
                                value: 'T.A.',
                                groupValue: selectedRoles,
                                onChanged: (value) => setState(() {
                                  selectedRoles = value;
                                }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: () async{
                              if (_formKey.currentState!.validate()){
                                if(selectedRoles==null){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Select Role of Faculty')));
                                  return;
                                }
                                var sp=await db_ref.child("Staff/faculty/${_idController.text.trim()}").get();
                                if(sp.exists){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Faculty Id is already Exists')));
                                  return;
                                }else{
                                  _addTeachingStaff();
                                }
                              }
                            },
                            child: Text("Add Faculty")
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add teaching staff to Firebase
  void _addTeachingStaff() {
    String name = _nameController.text.trim();
    String id = _idController.text.trim();
    String email = _emailController.text.trim();
    String qualification = _qualificationController.text.trim();

    bool flag=false;

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text("Verify Details"),
        content: Text(
            "Faculty Id:$id\n"
            "Faculty Name:$name\n"
            "Email:$email\n"
            "Qualifications:\n$qualification\n"
            "Role:$selectedRoles"
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Edit"),
          ),
          ElevatedButton(onPressed: () async{
            add();
            // //Save data under ID instead of random key
            // db_ref.child("Staff/faculty/$id").set({
            //   'name': name,
            //   'email': email,
            //   'qualification': qualification,
            //   'department': dept,
            //   'post': selectedRoles
            // }).then((_) {
            //   Navigator.pop(context);
            //   flag=true;
            // }).catchError((error) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text('Failed to add teaching staff: $error')));
            // });
            // Navigator.pop(context);
          }, child: Text("OK"))
        ],
      );
    });
    if(flag==true){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teaching Staff Added Successfully!')));
      Navigator.pop(context);
    }
  }

  void add() async{
    String name = _nameController.text.trim();
    String id = _idController.text.trim();
    String email = _emailController.text.trim();
    String qualification = _qualificationController.text.trim();

    //Save data under ID instead of random key
    db_ref.child("Staff/faculty/$id").set({
      'name': name,
      'email': email,
      'qualification': qualification,
      'department': dept,
      'post': selectedRoles
    }).then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add faculty: $error')));
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faculty added')));
  }
}
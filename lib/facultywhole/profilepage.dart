import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfileDetailPage extends StatefulWidget {
  //final Map<String, dynamic> staff;
  var id,flag;
  ProfileDetailPage({required this.id,required this.flag});

  @override
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late TextEditingController addressController;
  late TextEditingController phoneController;

  late faculty_model faculty_obj;

  late non_teaching_model staff_obj;

  bool islosding=true;

  @override
  void initState() {
    super.initState();
    print(widget.id);
    print(widget.flag);
    if(widget.flag==1){
      fetch_faculty();
    }else{
      fetch_staff();
    }
  }

  void fetch_faculty() async{
    var db=await FirebaseDatabase.instance.ref("Staff/faculty/${widget.id}").get();
    faculty_obj=faculty_model(
      department: db.child("department").value.toString(),
      email: db.child("email").value.toString(),
      name: db.child("name").value.toString(),
      post: db.child("post").value.toString(),
      qualification: db.child("qualification").value.toString(),
      exp: db.child("experience").exists?db.child("experience").value.toString():"N/A",
      address: db.child("address").exists?db.child("address").value.toString():"N/A",
      phone: db.child("phone").exists?db.child("phone").value.toString():"N/A",
      image: db.child("image").exists?db.child("image").value:null,
    );
    setState(() {
      islosding=false;
      addressController = TextEditingController(text:faculty_obj.address);
      phoneController = TextEditingController(text: faculty_obj.phone);
    });
  }

  void fetch_staff() async{
    var db=await FirebaseDatabase.instance.ref("Staff/non_teaching/${widget.id}").get();
    staff_obj=non_teaching_model(
      email: db.child("email").value.toString(),
      name: db.child("name").value.toString(),
      roles: db.child("roles").value,
      qualification: db.child("qualification").value.toString(),
      exp: db.child("experience").exists?db.child("experience").value.toString():"N/A",
      address: db.child("address").exists?db.child("address").value.toString():"N/A",
      phone: db.child("phone").exists?db.child("phone").value.toString():"N/A",
      image: db.child("profileImage").exists?db.child("profileImage").value:null,
    );
    setState(() {
      islosding=false;
      addressController = TextEditingController(text:staff_obj.address);
      phoneController = TextEditingController(text: staff_obj.phone);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_rounded,color: Colors.red,),
            onPressed: () => show_delete(),
          ),
        ],
      ),
      body: islosding==false
          ?
      Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: EdgeInsets.all(16),
        color: Colors.lightBlue[50],
        child:
        SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.flag==1
                  ?
              Column(
                children: [
                  faculty_obj.image==null?CircleAvatar(
                      radius: 50,
                      backgroundImage:
                      AssetImage("assets/images/faculty_icon.png")
                  ):CircleAvatar(
                    backgroundImage:MemoryImage(
                      base64Decode(faculty_obj.image.toString()),
                    ),
                    radius: 75,
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(Icons.numbers_outlined,  widget.id),
                  _buildInfoCard(Icons.person, faculty_obj.name),
                  _buildInfoCard(Icons.email, faculty_obj.email),
                  _buildInfoCard(Icons.school, faculty_obj.department),
                  _buildInfoCard(Icons.work, faculty_obj.post),
                  _buildInfoCard(Icons.location_on, faculty_obj.address),
                  _buildInfoCard(Icons.phone, faculty_obj.phone),
                  _buildInfoCard(Icons.school_outlined, faculty_obj.exp),
                ],
              )
                  :
              Column(
                children: [
                staff_obj.image==null ?
                CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    AssetImage("assets/images/faculty_icon.png")
                ) :
                CircleAvatar(
                  backgroundImage:MemoryImage(
                    base64Decode(staff_obj.image.toString()),
                  ),
                  radius: 75,
                ),
                SizedBox(height: 20),
                _buildInfoCard(Icons.numbers_outlined,  widget.id),
                _buildInfoCard(Icons.person, staff_obj.name),
                _buildInfoCard(Icons.email, staff_obj.email),
                _buildInfoCard(Icons.work, "${staff_obj.roles.join(' ')}"),
                _buildInfoCard(Icons.location_on, staff_obj.address),
                _buildInfoCard(Icons.phone, staff_obj.phone),
              ],
              ),
            ],
          ),
        )
      )
          :
      Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Address & Phone"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Address", addressController),
              _buildTextField("Phone", phoneController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _saveProfileChanges(),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText:label),
    );
  }

  void _saveProfileChanges() {
    setState(() {

    });
    Navigator.pop(context);
  }

  void show_delete(){
    showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Do you want to Delete?"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}


class faculty_model{
  String department,email,name,post,qualification;
  var image,exp,address,phone;
  faculty_model({
    required this.department,
    required this.email,
    required this.name,
    required this.post,
    required this.qualification,
    this.image,
    this.exp,
    this.address,
    this.phone
  });
}

class non_teaching_model{
  String email,name,qualification;
  var image,exp,address,phone,roles;
  non_teaching_model({
    required this.email,
    required this.name,
    required this.qualification,
    this.image,
    this.exp,
    this.address,
    this.phone,
    this.roles,
  });
}
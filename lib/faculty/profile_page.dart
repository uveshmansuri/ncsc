import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? uid,name,email,quali,dept,post;
  var img_encode;
  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  Future<void> _loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uname');
    if (uid != null) {
      try {
        var dbRef = FirebaseDatabase.instance.ref("Faculties");
        DataSnapshot sp = await dbRef.child(uid!).get();

        setState(() {
          name = sp.child("name").value?.toString() ?? "N/A";
          email = sp.child("email").value?.toString() ?? "N/A";
          quali = sp.child("qualification").value?.toString() ?? "N/A";
          dept = sp.child("department").value?.toString() ?? "N/A";
          post = sp.child("post").value?.toString() ?? "N/A";
          img_encode=sp.child("img").value;
        });
      } catch (e) {
        print("Error fetching faculty data: $e");
      }
    } else {
      print("UID is null");
    }
  }


  @override
  Widget build(BuildContext context){
    return Center(
      child:name==null?Text("Loading......"):Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Faculty Profile',
            style: TextStyle(fontSize: 20),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(360),
            child: Image.memory(base64Decode(img_encode),
              height: 75,
              width: 75,
              fit: BoxFit.fill,
            ),
          ),
          Text(
            'Name:- ${name}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Email:- ${email}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Post:- ${post}',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'Qualification:- ${quali}',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
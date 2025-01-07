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
          name = sp.child("name").value?.toString();
          email = sp.child("email").value?.toString();
          quali = sp.child("qualification").value?.toString();
          dept = sp.child("department").value?.toString();
          post = sp.child("post").value?.toString();
          img_encode=sp.child("img").value;
        });
      } catch (e) {
        //print("Error fetching faculty data: $e");
      }
    } else {
      //print("UID is null");
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Faculty Profile"),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0), // Center of the gradient
              radius: 1.0, // Spread of the gradient
              colors: [
                Color(0xFFE0F7FA),
                Color(0xffd1fbff),
              ],
              stops: [0.3,1.0],
              // colors: [
              //   Color(0xffb5ffff),Color(0xff89f7fe),Color(0xff00e4e4),
              // ],
            )
        ),
        child:
          name==null?Center(
            child: Container(
                height:50,
                width:50,
                child: CircularProgressIndicator()
            ),
          ): Center(
            child: Column(
              children:[
                Text(
                  'Faculty Profile',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                // RichText(
                //   text: TextSpan(
                //     children: [
                //       TextSpan(
                //         text: 'Name:- ',
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.teal.shade700,
                //         ),
                //       ),
                //       TextSpan(
                //         text: name,
                //         style: TextStyle(
                //           fontSize: 18,
                //           color: Colors.black87,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // RichText(
                //   text: TextSpan(
                //     children: [
                //       TextSpan(
                //         text: 'Email:- ',
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.teal.shade700,
                //         ),
                //       ),
                //       TextSpan(
                //         text: email,
                //         style: TextStyle(
                //           fontSize: 18,
                //           color: Colors.black87,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // RichText(
                //   text: TextSpan(
                //     children: [
                //       TextSpan(
                //         text: 'Department:- ',
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.teal.shade700,
                //         ),
                //       ),
                //       TextSpan(
                //         text: dept,
                //         style: TextStyle(
                //           fontSize: 18,
                //           color: Colors.black87,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // RichText(
                //   text: TextSpan(
                //     children: [
                //       TextSpan(
                //         text: 'Post:- ',
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.teal.shade700,
                //         ),
                //       ),
                //       TextSpan(
                //         text: post,
                //         style: TextStyle(
                //           fontSize: 18,
                //           color: Colors.black87,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: Image.memory(
                              base64Decode(img_encode),
                              height: 100,
                              width: 100,
                              fit: BoxFit.fill,
                            ),
                          ),
                          buildRichText("Name", name!),
                          buildRichText("Email", email!),
                          buildRichText("Department", dept!),
                          buildRichText("Post", post!),
                          buildRichText("Qualifications", "${quali!}"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
  Widget buildRichText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          // text: ">",
          // style: TextStyle(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.blueAccent
          // ),
          children: [
            TextSpan(
              text: '$title:-',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
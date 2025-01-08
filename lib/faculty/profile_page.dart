import 'dart:convert';

import 'package:NCSC/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        title: Text("Faculty Profile",
            style: TextStyle(
                color:Color(0xff0033ff),
                fontSize: 30,
                fontWeight: FontWeight.bold
            ),
        ),
        backgroundColor: Color(0xfff0f9f0),
      ),
      body: Center(
        child: Container(
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
                  // Text(
                  //   'Faculty Profile',
                  //   style: TextStyle(
                  //     fontSize: 40,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.teal.shade700,
                  //   ),
                  // ),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            elevation: 15,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(360),
                              side: BorderSide(
                                color: Colors.cyan, // Border color
                                width: 1.5,         // Border width
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(360),
                              child: Image.memory(
                                base64Decode(img_encode),
                                height: 100,
                                width: 100,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          build_item("$name", Icons.person),
                          SizedBox(height: 5,),
                          build_item("$email", Icons.mail_outline_sharp),
                          SizedBox(height: 5,),
                          build_item("$dept", Icons.account_balance),
                          SizedBox(height: 5,),
                          build_item("$post", Icons.work_outline),
                          SizedBox(height: 5,),
                          build_item("$quali", Icons.school_outlined),
                          SizedBox(height: 10,),
                          ElevatedButton.icon(
                              icon: Icon(Icons.logout,color: Colors.white,),
                              onPressed:()=>show_dialouge(context),
                              label: Text("Logout",
                                style: TextStyle(color: Colors.white,fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shadowColor: Colors.black,
                                elevation: 10,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              )
                          ),
                              // buildRichText("Name", name!),
                          // buildRichText("Email", email!),
                          // buildRichText("Department", dept!),
                          // buildRichText("Post", post!),
                          // buildRichText("Qualifications", "${quali!}"),
                          // SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget build_item(String value,IconData ic){
    return Card(
      elevation: 10,
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
    );
  }

  void show_dialouge(BuildContext context){
    showDialog(context: context,
      builder: (BuildContext context)=>
          AlertDialog(
            icon: Image.asset('assets/images/logo1.png',width: 80,height: 80,),
            title: Text("Confirm Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(onPressed:
                  () {
                Navigator.of(context).pop();
              },
                  child: Text("Cancel")
              ),
              TextButton(onPressed: logout,
                child: Text("Logout"),
              ),
            ],
          ),
    );
  }
  void logout() async{
    await FirebaseAuth.instance.signOut();
    SharedPreferences pref=await SharedPreferences.getInstance();
    pref.clear();
    pref.commit();
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>login()));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => login()),
      (Route<dynamic> route) => false,
    );
  }
  // Widget buildRichText(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: RichText(
  //       text: TextSpan(
  //         // text: ">",
  //         // style: TextStyle(
  //         //     fontSize: 20,
  //         //     fontWeight: FontWeight.bold,
  //         //     color: Colors.blueAccent
  //         // ),
  //         children: [
  //           TextSpan(
  //             text: '$title:-',
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.blueAccent
  //             ),
  //           ),
  //           TextSpan(
  //             text: value,
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.cyan,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
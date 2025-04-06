import 'dart:io';

import 'package:NCSC/DBADashboard.dart';
import 'package:NCSC/admin/admin_portal.dart';
import 'package:NCSC/faculty/faculty_home.dart';
import 'package:NCSC/faculty/main_faculty.dart';
import 'package:NCSC/main.dart';
import 'package:NCSC/registration.dart';
import 'package:NCSC/student/main_student.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services/Notification_Service.dart';
import 'nonteachingdashboard/commomdashboard.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController user_textcontrol = TextEditingController();
  TextEditingController pass_textcontrol = TextEditingController();
  bool password_visibility = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
              color: Color(0xff0033ff),
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xfff0f9f0),
      ),
      backgroundColor: Color(0xffb5ffff),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0),
                  radius: 1.0,
                  colors: [
                    Color(0xFFE0F7FA),
                    Color(0xffd1fbff),
                  ],
                  stops: [0.3, 1.0],
                )),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Image.asset("assets/images/collageimg.jpg"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Card(
                        color: Color(0xfff0f9f0),
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Image.asset("assets/images/logo1.png"),
                                height: 150,
                                width: 150,
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: user_textcontrol,
                                decoration: InputDecoration(
                                    labelText: "Enter User Name",
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(width: 1.5),
                                    )),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                obscureText: password_visibility,
                                controller: pass_textcontrol,
                                decoration: InputDecoration(
                                    labelText: "Enter Password",
                                    prefixIcon: Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          password_visibility = !password_visibility;
                                        });
                                      },
                                      icon: password_visibility
                                          ? Icon(Icons.visibility)
                                          : Icon(Icons.visibility_off),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(width: 1.5),
                                    )),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: isLoading ? null : loin_in,
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xff0000f0)),
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Registration()));
                                },
                                child: Text(
                                  "Click Here for Registration",
                                  style: TextStyle(color: Colors.black),
                                ),
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
          ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void loin_in() async {
    setState(() {
      isLoading = true;
    });

    String username = user_textcontrol.text.toString();
    String pass = pass_textcontrol.text.toString();
    bool found = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (username.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Enter Username");
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (pass.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Enter Password");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final databaseRef = FirebaseDatabase.instance.ref();
    DataSnapshot usersSnapshot = await databaseRef.child("Users").get();

    if(!kIsWeb){
      var token=await Notification_Service.getDeviceToken();
      await FirebaseDatabase.instance.ref("Users/$username")
          .child("token").set(token).then((_){
          });
    }

    for (DataSnapshot sp in usersSnapshot.children) {
      if (sp.child("user_name").value.toString() == username) {
        found = true;
        if (sp.child("password").value.toString() == pass) {
          String role = sp.child("role").value.toString();
          prefs.setBool('login_flag', true);
          prefs.setString('uname', username);
          prefs.setString('role', role);

          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isLoading = false;
            });
          });

          if (role == "admin") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => DBA_Dashboard()));
          } else if (role == "faculty") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => FacultyMain(username)));
          } else if (role == "student") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => StudentDashboard(stud_id: username,)));
          }
        } else {
          Fluttertoast.showToast(msg: "Invalid Password");
          setState(() {
            isLoading = false;
          });
        }
        break;
      }
    }

    if (!found) {
      DataSnapshot nonTeachingSnapshot =
      await databaseRef.child("Staff").child("non_teaching").get();
      for (DataSnapshot sp in nonTeachingSnapshot.children) {
        if (sp.key.toString() == username) {
          found = true;
          if (sp.child("password").value.toString() == pass) {
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                isLoading = false;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RoleBasedDashboard(username: username)));
            });
          } else {
            Fluttertoast.showToast(msg: "Invalid Password");
            setState(() {
              isLoading = false;
            });
          }
          break;
        }
      }
    }

    if (!found) {
      Fluttertoast.showToast(msg: "Invalid Username");
      setState(() {
        isLoading = false;
      });
    }
  }
}



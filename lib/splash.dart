import 'dart:async';
import 'package:NCSC/faculty/main_faculty.dart';
import 'package:NCSC/login.dart';
import 'package:NCSC/student/main_student.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DBADashboard.dart';

class splash extends StatefulWidget{
  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  void initState(){
    Timer(Duration(seconds: 4),() async{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>login()));
      final SharedPreferences prefs=await SharedPreferences.getInstance();
      if(prefs.getBool("login_flag")==true){
        if(prefs.getString("role")=="admin"){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context)=>DBA_Dashboard()
              )
          );
        }
        else if(prefs.getString("role")=="faculty"){
          var username=prefs.getString("uname");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => FacultyMain(username!)));
        }else if(prefs.getString("role")=="student"){
          var username=prefs.getString("uname");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => StudentDashboard(stud_id: username!,)));
        }
      }else{
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context)=>login())
        );
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffb5ffff),Color(0xff89f7fe),Color(0xff00e4e4),
                  ],
                )
            ),
            child: Center(
              child:Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    SizedBox(
                      child: Image.asset("assets/images/logo1.png"),
                      height: 260,
                      width: 230,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text("Narmada College",style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30
                          ),),
                          Text("of",style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30
                          ),),
                          Text("Science and Commerce",style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30
                          ),),
                          SizedBox(height: 30,),
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                              backgroundColor: Colors.grey,
                              strokeWidth: 5.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
        ),
        bottomNavigationBar:Text("Developed By USM")
    );*/
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent,Colors.white],)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo1.png",height: 220,width: 240,),
                SizedBox(height: 20,),
                Text("Narmada College\nof\nScience and Commerce",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 10,),
                 CircularProgressIndicator(),
                //Lottie.asset("assets/animations/dba_loading.json",height: 150,width: 150),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Text("Developed by Bittu Agarwal, Uvesh Mansuri, Nilay Mahant",textAlign: TextAlign.center,),
    );
  }
}
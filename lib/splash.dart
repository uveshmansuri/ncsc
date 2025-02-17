import 'dart:async';
import 'package:NCSC/admin/admin_portal.dart';
import 'package:NCSC/faculty/faculty_home.dart';
import 'package:NCSC/faculty/main_faculty.dart';
import 'package:NCSC/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class splash extends StatefulWidget{
  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  void initState(){
    Timer(Duration(seconds: 4),() async {
      // final SharedPreferences prefs =await SharedPreferences.getInstance();
      // if(prefs.getBool("login_flag")==true){
      //   //print(prefs.getString("role"));
      //   if(prefs.getString("role")=="admin"){
      //     Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context)=>admin_portal()
      //         )
      //     );
      //   }
      //   if(prefs.getString("role")=="faculty"){
      //     Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context)=>FacultyMain()
      //         )
      //     );
      //   }
      // }else{
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context)=>login())
      //   );
      // }
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
                CircularProgressIndicator(),
                SizedBox(height: 40,),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Text("Developed by USM",textAlign: TextAlign.center,),
    );
  }
}
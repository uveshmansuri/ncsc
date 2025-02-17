import 'dart:async';
import 'package:NCSC/faculty/faculty_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class email_verification extends StatefulWidget{
  var email_id,user_name,pass,role;
  email_verification(this.email_id,this.user_name,this.pass,this.role);
  @override
  State<email_verification> createState() => _email_verificationState(user_name,pass,role);
}

class _email_verificationState extends State<email_verification> {
  var user_name,pass,role;
  late Timer timer1;
  _email_verificationState(this.user_name,this.pass,this.role);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer1=Timer.periodic(Duration(seconds: 2), (timer){
      FirebaseAuth.instance.currentUser?.reload();
      if(FirebaseAuth.instance.currentUser!.emailVerified){
        add_user_details(user_name,pass,role);
        timer.cancel();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Email Verification"),
      ),body: Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0), // Center of the gradient
          radius: 1.0, // Spread of the gradient
          colors: [
            Color(0xFFE0F7FA),
            Color(0xffd1fbff),
          ],
          stops: [0.3,1.0],
        )),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Card(
              elevation: 30,
              color: Color(0xfff0f9f0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10,),
                    Icon(Icons.email_sharp,size: 50,color: Colors.blue,),
                    Text("Verify Email",style: TextStyle(fontSize: 50,color: Colors.blue),),
                    SizedBox(height: 30,),
                    Text("Verification Email is sent to your Email ID ${widget.email_id}"),
                    SizedBox(height: 30,),
                    //ElevatedButton(onPressed: , child: Text("Verify")),
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void add_user_details(user_name,pass,role) async{
    await FirebaseDatabase.instance.ref().child("Users").child(user_name).set({
      "user_name":user_name,
      "password":pass,
      "role":role
    }).then((_) async{
      Fluttertoast.showToast(msg: "Registration Successful!!!");
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('login_flag', true);
      // await prefs.setString('uname', user_name);
      // await prefs.setString('role', "faculty");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => faculty_home()),
            (route) => false, // Remove all previous routes
      );
    });
  }
}
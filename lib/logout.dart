import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class logout{

  void log_out(BuildContext context) async{
    final pr=await SharedPreferences.getInstance();
    pr.clear();
    pr.setBool("login_flag", false);
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>login()));
  }

  void show_dialouge(BuildContext context) {
    showDialog(context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            icon: Image.asset(
              'assets/images/logo1.png', width: 80, height: 80,),
            title: Text("Confirm Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(onPressed:
                  () {
                Navigator.of(context).pop();
              },
                  child: Text("Cancel")
              ),
              TextButton(onPressed: () => log_out(context),
                child: Text("Logout"),
              ),
            ],
          ),
    );
  }
}
import 'package:NCSC/admin/admin_portal.dart';
import 'package:NCSC/faculty/faculty_home.dart';
import 'package:NCSC/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class regestration extends StatefulWidget{
  @override
  State<regestration> createState() => _regestrationState();
}

class _regestrationState extends State<regestration> {
  TextEditingController user_textcontrol=TextEditingController();
  TextEditingController pass_textcontrol=TextEditingController();
  TextEditingController confirm_pass_textcontrol=TextEditingController();

  var password_visibility=true;
  var con_pass_visibility=true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffF0F9F0),
          title: Text("Registration"),
          bottom: TabBar(tabs:[Tab(text: "Faculty",),Tab(text: "Student",)]),
        ),
        body: Container(
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
              )
          ),
          child: TabBarView(
            children: [
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: Card(
                          color: Color(0xfff0f9f0),
                          elevation: 20,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/faculty_icon.png",height: 75,width: 75,),
                                    SizedBox(width: 30,),
                                    Text("Faculty\nRegistration",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 30,fontWeight: FontWeight.bold,color: Color(0xff0000f0)
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  controller: user_textcontrol,
                                  decoration: InputDecoration(
                                      labelText: "Enter Faculty Id",
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 1.5),
                                      )
                                  ),
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  obscureText: password_visibility,
                                  controller: pass_textcontrol,
                                  decoration: InputDecoration(
                                      labelText: "Enter Password",
                                      prefixIcon: Icon(Icons.lock),
                                      suffixIcon: IconButton(onPressed: (){
                                        setState(() {
                                          password_visibility=!password_visibility;
                                        });
                                      }, icon: password_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 1.5),
                                      )
                                  ),
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  obscureText: con_pass_visibility,
                                  controller: confirm_pass_textcontrol,
                                  decoration: InputDecoration(
                                      labelText: "Confirm Password",
                                      prefixIcon: Icon(Icons.lock),
                                      suffixIcon: IconButton(onPressed: (){
                                        setState(() {
                                          con_pass_visibility=!con_pass_visibility;
                                        });
                                      }, icon: con_pass_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 1.5),
                                      )
                                  ),
                                ),
                                SizedBox(height: 10,),
                                ElevatedButton(
                                    onPressed:faculty_reg, child:
                                Text(
                                  "Register",
                                  style: TextStyle(
                                      fontSize: 20,color: Color(0xff0000f0)
                                  ),
                                )
                                ),
                                SizedBox(height: 20,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: Card(
                          color: Color(0xfff0f9f0),
                          elevation: 20,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/student_profile.png",height: 75,width: 75,),
                                    SizedBox(width: 30,),
                                    Text("Student\nRegistration",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 30,fontWeight: FontWeight.bold,color: Color(0xff0000f0)
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  controller: user_textcontrol,
                                  decoration: InputDecoration(
                                      labelText: "Enter Student Id",
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 1.5),
                                      )
                                  ),
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  obscureText: password_visibility,
                                  controller: pass_textcontrol,
                                  decoration: InputDecoration(
                                      labelText: "Enter Password",
                                      prefixIcon: Icon(Icons.lock),
                                      suffixIcon: IconButton(onPressed: (){
                                        setState(() {
                                          password_visibility=!password_visibility;
                                        });
                                      }, icon: password_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 1.5),
                                      )
                                  ),
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                  obscureText: con_pass_visibility,
                                  controller: confirm_pass_textcontrol,
                                  decoration: InputDecoration(
                                      labelText: "Confirm Password",
                                      prefixIcon: Icon(Icons.lock),
                                      suffixIcon: IconButton(onPressed: (){
                                        setState(() {
                                          con_pass_visibility=!con_pass_visibility;
                                        });
                                      }, icon: con_pass_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 1.5),
                                      )
                                  ),
                                ),
                                SizedBox(height: 10,),
                                ElevatedButton(
                                    onPressed: (){}, child:
                                Text(
                                  "Register",
                                  style: TextStyle(
                                      fontSize: 20,color: Color(0xff0000f0)
                                  ),
                                )
                                ),
                                SizedBox(height: 20,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  void faculty_reg() async{
    bool flag=false;
    final fr_db=FirebaseDatabase.instance.ref().child("Faculties");
    DataSnapshot snapshot=await fr_db.get();
    if(validate_input()){
      for(DataSnapshot sp in snapshot.children){
        if(sp.child("faculty_id").value.toString()==user_textcontrol.text) {
          flag = true;
          FirebaseAuth _auth=FirebaseAuth.instance;
          try {
            final user_cred=await _auth.createUserWithEmailAndPassword(
                email: sp.child("email").value.toString(),
                password: pass_textcontrol.text.toString()
            );
            //Fluttertoast.showToast(msg: "Registration Successful");
            await FirebaseDatabase.instance.ref().child("Users").child(user_textcontrol.text).set({
              "user_name":user_textcontrol.text,
              "password":pass_textcontrol.text.toString(),
              "role":"faculty"
            }).then((_){
              Fluttertoast.showToast(msg: "Registration Successful!!!");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => faculty_home()),
                    (route) => false, // Remove all previous routes
              );
            });
          } on FirebaseAuthException catch (e) {
            Fluttertoast.showToast(msg: "${e.message}");
          }finally{
          }
        }
      }
      if(!flag){
        Fluttertoast.showToast(msg: "Invalid Faculty Id");
      }
    }else{
    }
  }

  bool validate_input(){
    if(user_textcontrol.text.length==0){
      Fluttertoast.showToast(msg: "Please Enter Faculty Id");
      return false;
    }
    if(pass_textcontrol.text.length==0){
      Fluttertoast.showToast(msg: "Please Enter Password");
      return false;
    }
    if(pass_textcontrol.text.length<6){
      Fluttertoast.showToast(msg: "Passwords length must be 6 character long");
      return false;
    }
    if(confirm_pass_textcontrol.text.length==0 || confirm_pass_textcontrol.text.toString()!=pass_textcontrol.text.toString()){
      Fluttertoast.showToast(msg: "Please Confirm Password");
      return false;
    }
    return true;
  }
}
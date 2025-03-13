import 'package:NCSC/admin/admin_portal.dart';
import 'package:NCSC/email_verification.dart';
import 'package:NCSC/faculty/main_faculty.dart';
import 'package:NCSC/login.dart';
import 'package:NCSC/student/main_student.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class regestration extends StatefulWidget {
  @override
  State<regestration> createState() => _RegistrationState();
}

class _RegistrationState extends State<regestration> {
  TextEditingController userTextController = TextEditingController();
  TextEditingController passTextController = TextEditingController();
  TextEditingController confirmPassTextController = TextEditingController();

  bool passwordVisibility = true;
  bool confirmPassVisibility = true;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffF0F9F0),
          title: Text(
            "Registration",
            style: TextStyle(
                color: Color(0xff0033ff),
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelStyle: TextStyle(fontSize: 20.0, color: Colors.lightBlue),
            unselectedLabelStyle:
            TextStyle(fontSize: 15.0, color: Colors.grey),
            tabs: [
              Tab(text: "Faculty"),
              Tab(text: "Student"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildRegistrationForm("faculty"),
            buildRegistrationForm("student"),
          ],
        ),
      ),
    );
  }

  Widget buildRegistrationForm(String role) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Card(
            color: Color(0xfff0f9f0),
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        role == "faculty"
                            ? "assets/images/faculty_icon.png"
                            : "assets/images/student_profile.png",
                        height: 75,
                        width: 75,
                      ),
                      SizedBox(width: 30),
                      Text(
                        "${role.capitalize()}\nRegistration",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0000f0)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: userTextController,
                    decoration: InputDecoration(
                        labelText: "Enter ${role.capitalize()} ID",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1.5),
                        )),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    obscureText: passwordVisibility,
                    controller: passTextController,
                    decoration: InputDecoration(
                        labelText: "Enter Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisibility = !passwordVisibility;
                            });
                          },
                          icon: passwordVisibility
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1.5),
                        )),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    obscureText: confirmPassVisibility,
                    controller: confirmPassTextController,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              confirmPassVisibility = !confirmPassVisibility;
                            });
                          },
                          icon: confirmPassVisibility
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
                    onPressed: role == "faculty" ? facultyReg : studentReg,
                    child: Text(
                      "Register",
                      style: TextStyle(fontSize: 20, color: Color(0xff0000f0)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void facultyReg() async {
    final dbRef = FirebaseDatabase.instance.ref().child("Faculty");
    processRegistration(dbRef, "faculty", (String id) => FacultyMain(id));
  }

  void studentReg() async {
    final dbRef = FirebaseDatabase.instance.ref().child("Students");
    processRegistration(dbRef, "student", (String id) => StudentDashboard(stud_id: id));
  }



  void processRegistration(
      DatabaseReference dbRef, String role, Widget Function(String) homePage) async {
    if (validateInput()) {
      final snapshot = await dbRef.get();
      bool exists = false;
      String email = "";
      String studentName = "";

      for (final sp in snapshot.children) {
        if (sp.key == userTextController.text) {
          exists = true;
          email = sp.child("email").value.toString();
          studentName = sp.child("name").value.toString();
          break;
        }
      }

      if (exists) {
        try {
          await _auth.createUserWithEmailAndPassword(
              email: email, password: passTextController.text);
          if (role == "student") {
            // For students, send verification email and navigate to the email_verification page.
            sendEmail(email, userTextController.text, passTextController.text, role);
          } else if (role == "faculty") {
            // For faculty, navigate directly to the faculty home page.
                sendEmail(email, userTextController.text, passTextController.text, role);
          }
        } catch (e) {
          Fluttertoast.showToast(msg: e.toString());
        }
      } else {
        Fluttertoast.showToast(msg: "Invalid User ID");
      }
    }
}

  void sendEmail(String email, String userName, String pass, String role) async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => email_verification(email, userName, pass, role)));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  bool validateInput() {
    if (userTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter an ID");
      return false;
    }
    if (passTextController.text.isEmpty || passTextController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters long");
      return false;
    }
    if (confirmPassTextController.text != passTextController.text) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return false;
    }
    return true;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}









// import 'package:NCSC/admin/admin_portal.dart';
// import 'package:NCSC/email_verification.dart';
// import 'package:NCSC/faculty/faculty_home.dart';
// import 'package:NCSC/login.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class regestration extends StatefulWidget{
//   @override
//   State<regestration> createState() => _regestrationState();
// }
//
// class _regestrationState extends State<regestration> {
//   TextEditingController user_textcontrol=TextEditingController();
//   TextEditingController pass_textcontrol=TextEditingController();
//   TextEditingController confirm_pass_textcontrol=TextEditingController();
//
//   var password_visibility=true;
//   var con_pass_visibility=true;
//
//   var user_cred;
//
//   final _auth=FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Color(0xffF0F9F0),
//           title: Text("Registration",
//             style: TextStyle(
//               color:Color(0xff0033ff),
//               fontSize: 25,
//               fontWeight: FontWeight.bold
//             ),
//           ),
//           bottom: TabBar(
//               indicatorColor: Colors.blue,
//               labelStyle: TextStyle(fontSize: 20.0,color: Colors.lightBlue),
//               unselectedLabelStyle: TextStyle(fontSize: 15.0,color: Colors.grey),
//               tabs: [
//                 Tab(text: "Faculty",),
//                 Tab(text: "Student",)
//               ]
//           ),
//         ),
//         body: Container(
//           height: double.infinity,
//           decoration: BoxDecoration(
//               gradient: RadialGradient(
//                 center: Alignment(0, 0), // Center of the gradient
//                 radius: 1.0, // Spread of the gradient
//                 colors: [
//                   Color(0xFFE0F7FA),
//                   Color(0xffd1fbff),
//                 ],
//                 stops: [0.3,1.0],
//               )
//           ),
//           child: TabBarView(
//             children: [
//               Center(
//                 child: SingleChildScrollView(
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//                           child: Card(
//                             color: Color(0xfff0f9f0),
//                             elevation: 20,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10,),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   SizedBox(height: 30,),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Image.asset("assets/images/faculty_icon.png",height: 75,width: 75,),
//                                       SizedBox(width: 30,),
//                                       Text("Faculty\nRegistration",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 30,fontWeight: FontWeight.bold,color: Color(0xff0000f0)
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 20,),
//                                   TextFormField(
//                                     controller: user_textcontrol,
//                                     decoration: InputDecoration(
//                                         labelText: "Enter Faculty Id",
//                                         prefixIcon: Icon(Icons.person),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                           borderSide: BorderSide(width: 1.5),
//                                         )
//                                     ),
//                                   ),
//                                   SizedBox(height: 10,),
//                                   TextFormField(
//                                     obscureText: password_visibility,
//                                     controller: pass_textcontrol,
//                                     decoration: InputDecoration(
//                                         labelText: "Enter Password",
//                                         prefixIcon: Icon(Icons.lock),
//                                         suffixIcon: IconButton(onPressed: (){
//                                           setState(() {
//                                             password_visibility=!password_visibility;
//                                           });
//                                         }, icon: password_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                           borderSide: BorderSide(width: 1.5),
//                                         )
//                                     ),
//                                   ),
//                                   SizedBox(height: 10,),
//                                   TextFormField(
//                                     obscureText: con_pass_visibility,
//                                     controller: confirm_pass_textcontrol,
//                                     decoration: InputDecoration(
//                                         labelText: "Confirm Password",
//                                         prefixIcon: Icon(Icons.lock),
//                                         suffixIcon: IconButton(onPressed: (){
//                                           setState(() {
//                                             con_pass_visibility=!con_pass_visibility;
//                                           });
//                                         }, icon: con_pass_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                           borderSide: BorderSide(width: 1.5),
//                                         )
//                                     ),
//                                   ),
//                                   SizedBox(height: 10,),
//                                   ElevatedButton(
//                                       onPressed:faculty_reg, child:
//                                   Text(
//                                     "Register",
//                                     style: TextStyle(
//                                         fontSize: 20,color: Color(0xff0000f0)
//                                     ),
//                                   )
//                                   ),
//                                   SizedBox(height: 20,)
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: SingleChildScrollView(
//                   child: Center(
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//                           child: Card(
//                             color: Color(0xfff0f9f0),
//                             elevation: 20,
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   SizedBox(height: 30,),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Image.asset("assets/images/student_profile.png",height: 75,width: 75,),
//                                       SizedBox(width: 30,),
//                                       Text("Student\nRegistration",
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 30,fontWeight: FontWeight.bold,color: Color(0xff0000f0)
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 20,),
//                                   TextFormField(
//                                     controller: user_textcontrol,
//                                     decoration: InputDecoration(
//                                         labelText: "Enter Student Id",
//                                         prefixIcon: Icon(Icons.person),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                           borderSide: BorderSide(width: 1.5),
//                                         )
//                                     ),
//                                   ),
//                                   SizedBox(height: 10,),
//                                   TextFormField(
//                                     obscureText: password_visibility,
//                                     controller: pass_textcontrol,
//                                     decoration: InputDecoration(
//                                         labelText: "Enter Password",
//                                         prefixIcon: Icon(Icons.lock),
//                                         suffixIcon: IconButton(onPressed: (){
//                                           setState(() {
//                                             password_visibility=!password_visibility;
//                                           });
//                                         }, icon: password_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                           borderSide: BorderSide(width: 1.5),
//                                         )
//                                     ),
//                                   ),
//                                   SizedBox(height: 10,),
//                                   TextFormField(
//                                     obscureText: con_pass_visibility,
//                                     controller: confirm_pass_textcontrol,
//                                     decoration: InputDecoration(
//                                         labelText: "Confirm Password",
//                                         prefixIcon: Icon(Icons.lock),
//                                         suffixIcon: IconButton(onPressed: (){
//                                           setState(() {
//                                             con_pass_visibility=!con_pass_visibility;
//                                           });
//                                         }, icon: con_pass_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(20),
//                                           borderSide: BorderSide(width: 1.5),
//                                         )
//                                     ),
//                                   ),
//                                   SizedBox(height: 10,),
//                                   ElevatedButton(
//                                       onPressed: (){}, child:
//                                   Text(
//                                     "Register",
//                                     style: TextStyle(
//                                         fontSize: 20,color: Color(0xff0000f0)
//                                     ),
//                                   )
//                                   ),
//                                   SizedBox(height: 20,)
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ),
//     );
//   }
//
//   void faculty_reg() async{
//     String email,pass;
//     bool flag=false;
//     final fr_db=FirebaseDatabase.instance.ref().child("Staff/faculty");
//     DataSnapshot snapshot=await fr_db.get();
//     if(validate_input()){
//       for(DataSnapshot sp in snapshot.children){
//         if(sp.key==user_textcontrol.text) {
//           flag=true;
//           email=sp.child("email").value.toString();
//           pass=pass_textcontrol.text;
//           await _auth.createUserWithEmailAndPassword(email: email, password: pass)
//               .then((_) {
//                 send_email(email,user_textcontrol.text,pass,"faculty");
//           })
//               .catchError((error){
//                 Fluttertoast.showToast(msg: error.toString());
//           });
//         }
//       }
//       if(!flag){
//         Fluttertoast.showToast(msg: "Invalid User Id");
//       }
//     }
//   }
//
//
//   void send_email(email,user_name,pass,role) async{
//     try{
//       await _auth.currentUser?.sendEmailVerification();
//       Navigator.push(context, MaterialPageRoute(builder: (context)=>email_verification(email,user_name,pass,role)));
//     }catch(e){
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//   bool validate_input(){
//     if(user_textcontrol.text.length==0){
//       Fluttertoast.showToast(msg: "Please Enter Faculty Id");
//       return false;
//     }
//     if(pass_textcontrol.text.length==0){
//       Fluttertoast.showToast(msg: "Please Enter Password");
//       return false;
//     }
//     if(pass_textcontrol.text.length<6){
//       Fluttertoast.showToast(msg: "Passwords length must be 6 character long");
//       return false;
//     }
//     if(confirm_pass_textcontrol.text.length==0 || confirm_pass_textcontrol.text.toString()!=pass_textcontrol.text.toString()){
//       Fluttertoast.showToast(msg: "Please Confirm Password");
//       return false;
//     }
//     return true;
//   }
// }
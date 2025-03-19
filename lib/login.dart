import 'package:NCSC/DBADashboard.dart';
import 'package:NCSC/admin/admin_portal.dart';
import 'package:NCSC/faculty/faculty_home.dart';
import 'package:NCSC/faculty/main_faculty.dart';
import 'package:NCSC/main.dart';
import 'package:NCSC/registration.dart';
import 'package:NCSC/student/main_student.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nonteachingdashboard/commomdashboard.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController user_textcontrol = TextEditingController();
  TextEditingController pass_textcontrol = TextEditingController();

  bool isloading=false;
  bool password_visibility = true;

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
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                  onPressed: loin_in,
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                        fontSize: 20, color: Color(0xff0000f0)),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => regestration()));
                                  },
                                  child: Text(
                                    "Click Here for Registration",
                                    style: TextStyle(color: Colors.black),
                                  ))
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
          if(isloading==true)
            Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }

  void loin_in() async {
    String username = user_textcontrol.text.toString();
    String pass = pass_textcontrol.text.toString();
    bool found = false;

    SharedPreferences prefs=await SharedPreferences.getInstance();

    if (username.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Enter Username",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    if (pass.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Enter Password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      isloading=true;
    });
    final databaseRef = FirebaseDatabase.instance.ref();
    DataSnapshot usersSnapshot = await databaseRef.child("Users").get();
    for (DataSnapshot sp in usersSnapshot.children) {
      if (sp.child("user_name").value.toString() == username) {
        found = true;
        if (sp.child("password").value.toString() == pass) {
          String role = sp.child("role").value.toString();
          if (role == "admin") {
            prefs.setBool('login_flag', true);
            prefs.setString('uname', username);
            prefs.setString('role', role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DBA_Dashboard()));
          }
          else if (role == "faculty") {
            prefs.setBool('login_flag', true);
            prefs.setString('uname', username);
            prefs.setString('role', role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => FacultyMain(username)));
          }
          else if (role == "student") {
            prefs.setBool('login_flag', true);
            prefs.setString('uname', username);
            prefs.setString('role', role);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => StudentDashboard(stud_id: username,)));
          }
        }
        else {
          setState(() {
            isloading=false;
          });
          Fluttertoast.showToast(
            msg: "Invalid Password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
        break;
      }
    }

    if (!found) {
      DataSnapshot nonTeachingSnapshot =
      await databaseRef.child("Staff").child("non_teaching").get();
      print("Non teaching snapshot: ${nonTeachingSnapshot.value}");
      for (DataSnapshot sp in nonTeachingSnapshot.children) {
        print("Checking non teaching user key: ${sp.key}");
        // Assuming the non-teaching username is stored as the key (e.g., "STF101")
        if (sp.key.toString() == username) {
          found = true;
          if (sp.child("password").value.toString() == pass) {
            print("Non teaching user found");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RoleBasedDashboard(username: username)));
          } else {
            setState(() {
              isloading=false;
            });
            Fluttertoast.showToast(
              msg: "Invalid Password",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
          break;
        }
      }
    }

    if (!found) {
      setState(() {
        isloading=false;
      });
      Fluttertoast.showToast(
        msg: "Invalid Username",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      print("User not found");
    }
  }
}

// import 'package:NCSC/DBADashboard.dart';
// import 'package:NCSC/admin/admin_portal.dart';
// import 'package:NCSC/faculty/faculty_home.dart';
// import 'package:NCSC/faculty/main_faculty.dart';
// import 'package:NCSC/main.dart';
// import 'package:NCSC/registration.dart';
// import 'package:NCSC/student/main_student.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
//
// class login extends StatefulWidget{
//   @override
//   State<login> createState() => _loginState();
// }
//
// class _loginState extends State<login> {
//   TextEditingController user_textcontrol=TextEditingController();
//   TextEditingController pass_textcontrol=TextEditingController();
//
//   bool password_visibility=true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Login",
//           style: TextStyle(
//               color:Color(0xff0033ff),
//               fontSize: 30,
//               fontWeight: FontWeight.bold
//           ),
//         ),
//         backgroundColor: Color(0xfff0f9f0),
//       ),
//       backgroundColor: Color(0xffb5ffff),
//       body: Container(
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment(0, 0), // Center of the gradient
//             radius: 1.0, // Spread of the gradient
//             colors: [
//               Color(0xFFE0F7FA),
//               Color(0xffd1fbff),
//             ],
//             stops: [0.3,1.0],
//             // colors: [
//             //   Color(0xffb5ffff),Color(0xff89f7fe),Color(0xff00e4e4),
//             // ],
//           )
//         ),
//         child: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [
//                 Image.asset("assets/images/collageimg.jpg"),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
//                   child: Card(
//                     color: Color(0xfff0f9f0),
//                     elevation: 20,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20,),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             child: Image.asset("assets/images/logo1.png"),
//                             height: 150,
//                             width: 150,
//                           ),
//                           SizedBox(height: 10,),
//                           TextFormField(
//                             controller: user_textcontrol,
//                             decoration: InputDecoration(
//                               labelText: "Enter User Name",
//                               prefixIcon: Icon(Icons.person),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                                 borderSide: BorderSide(width: 1.5),
//                               )
//                             ),
//                           ),
//                           SizedBox(height: 10,),
//                           TextFormField(
//                             obscureText: password_visibility,
//                             controller: pass_textcontrol,
//                             decoration: InputDecoration(
//                                 labelText: "Enter Password",
//                                 prefixIcon: Icon(Icons.lock),
//                                 suffixIcon: IconButton(onPressed: (){
//                                   setState(() {
//                                     password_visibility=!password_visibility;
//                                   });
//                                 }, icon: password_visibility ? Icon(Icons.visibility) : Icon(Icons.visibility_off),),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                   borderSide: BorderSide(width: 1.5),
//                                 )
//                             ),
//                           ),
//                           SizedBox(height: 10,),
//                           ElevatedButton(
//                               onPressed: loin_in, child:
//                               Text(
//                                 "Login",
//                                 style: TextStyle(
//                                   fontSize: 20,color: Color(0xff0000f0)
//                                 ),
//                               )
//                           ),
//                           TextButton(onPressed: (){
//                             Navigator.push(context, MaterialPageRoute(builder: (context)=>regestration()));
//                           }, child:
//                               Text("Click Here for Registration",style:
//                                 TextStyle(
//                                   color: Colors.black
//                                 ),
//                               )
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void loin_in() async{
//     String username=user_textcontrol.text.toString();
//     String pass=pass_textcontrol.text.toString();
//     int flag=0;
//     if(username.trim().length==0){
//       Fluttertoast.showToast(
//           msg: "Enter Usernane",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//       );
//     }else if(pass.trim().length==0){
//       Fluttertoast.showToast(
//         msg: "Enter Password",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//       );
//     }else{
//       final databaseRef = FirebaseDatabase.instance.ref();
//       DataSnapshot snapshot=await databaseRef.child("Users").get();
//       //print(snapshot.child("admin101").child("user_name").value.toString());
//       for(DataSnapshot sp in snapshot.children){
//         //print(sp.child("user_name").value.toString());
//         if(sp.child("user_name").value.toString()==username){
//           if(sp.child("password").value.toString()==pass){
//             flag=1;
//             if(sp.child("role").value.toString()=="admin"){
//               //print("Admin");
//               // final SharedPreferences prefs = await SharedPreferences.getInstance();
//               // await prefs.setBool('login_flag', true);
//               // await prefs.setString('uname', username);
//               // await prefs.setString('role', "admin");
//               //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>));
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DBA_Dashboard()));
//             }
//             if(sp.child("role").value.toString()=="faculty"){
//               // final SharedPreferences prefs = await SharedPreferences.getInstance();
//               // await prefs.setBool('login_flag', true);
//               // await prefs.setString('uname', username);
//               // await prefs.setString('role', "faculty");
//               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FacultyMain(username)));
//             }
//           if(sp.child("role").value.toString()=="student"){
//             // final SharedPreferences prefs = await SharedPreferences.getInstance();
//             // await prefs.setBool('login_flag', true);
//             // await prefs.setString('uname', username);
//             // await prefs.setString('role', "faculty");
//             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StudentDashboard()));
//           }}else{
//             flag=1;
//             Fluttertoast.showToast(
//               msg: "Invalid Password",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//             );
//           }
//         }
//       }
//       if(flag==0){
//         Fluttertoast.showToast(
//           msg: "Invalid Usernane",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//         );
//       }
//     }
//   }
// }
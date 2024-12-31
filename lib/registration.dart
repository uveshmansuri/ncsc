import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xfff0f9f0),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Image.asset("assets/images/logo1.png"),
                                  height: 150,
                                  width: 150,
                                ),
                                Text("Faculty Registration",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 40,fontWeight: FontWeight.bold,color: Color(0xff0000f0)
                                  ),
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
              ),
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xfff0f9f0),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Image.asset("assets/images/logo1.png"),
                                  height: 150,
                                  width: 150,
                                ),
                                Text("Student Registration",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 40,fontWeight: FontWeight.bold,color: Color(0xff0000f0)
                                  ),
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
}
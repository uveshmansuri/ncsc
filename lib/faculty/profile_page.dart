import 'dart:convert';
import 'dart:io';

import 'package:NCSC/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? uid,name,email,quali,dept,post,address,phone;
  var img_encode,temProfileImageBase64;

  final TextEditingController phonebox = TextEditingController();
  final TextEditingController addbox = TextEditingController();

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
          phone = sp.child("phone").value?.toString();
          address = sp.child("address").value?.toString();
          img_encode=sp.child("img").value;
        });
      } catch (e) {
        //print("Error fetching faculty data: $e");
      }
    } else {
      //print("UID is null");
    }
  }
  Future<void> _saveChanges() async {
    var dbRef = FirebaseDatabase.instance.ref("Faculties");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uname');
    if(temProfileImageBase64!=null){
      img_encode = temProfileImageBase64;
    }
    if (uid != null) {
      try {
        await dbRef.child(uid!)?.update({
          "phone": phonebox.text,
          "address": addbox.text,
          "img": img_encode,
        });
        setState(() {
          if(phonebox.text!=null){
            phone=phonebox.text;
          }
          if(addbox.text!=null){
            address=addbox.text;
          }
          if(temProfileImageBase64!=null){
            img_encode = temProfileImageBase64;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile Updated Successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64String = base64Encode(imageBytes);
        setState(() {
          temProfileImageBase64 = base64String;
        });
      } catch (e) {
        print("Error converting image to Base64: $e");
      }
    }
  }
  void EditDialog() {
    phonebox.text = phone!;
    addbox.text = address!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(360),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(360),
                              child: Image.memory(
                                base64Decode(temProfileImageBase64 ?? img_encode!),
                                height: 125,
                                width: 125,
                                fit: BoxFit.fill,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                print("OK");
                                await pickImage();
                                setState(() {});
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 20,
                                child: Icon(Icons.edit, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: phonebox,
                        decoration: InputDecoration(
                          labelText: phone!.length==0? "Mobile No":"",
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.phone_android_rounded,color: Colors.cyan,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: addbox,
                        decoration: InputDecoration(
                          labelText: address!.length==0? "Address":"",
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.maps_home_work_rounded,color: Colors.cyan,),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if(temProfileImageBase64!=null){
                                  img_encode = temProfileImageBase64;
                                }
                              });
                              _saveChanges();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: EditDialog,
          ),
        ],
        backgroundColor: Color(0xfff0f9f0),
      ),
      body: Container(
        height: double.maxFinite,
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
        child:
          name==null?
          Center(
            child: Container(
                height:50,
                width:50,
                child: CircularProgressIndicator()
            ),
          ):
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15,),
                Material(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(360),
                    side: BorderSide(
                      color: Colors.cyan, // Border color
                      width: 2,         // Border width
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(360),
                    child: Image.memory(
                      base64Decode(img_encode),
                      height: 150,
                      width: 150,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                build_item("$name", Icons.person),
                build_item("$email", Icons.mail_outline_sharp),
                build_item("$dept", Icons.account_balance),
                build_item("$post", Icons.work_outline),
                build_item("$quali", Icons.school_outlined),
                if(address!=null && address!.length>0)
                  build_item("$address", Icons.home_work_sharp),
                if(phone!=null && phone!.length>0)
                  build_item("$phone", Icons.phone_android_rounded),
                SizedBox(height: 15,),
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
                SizedBox(height: 15,),
              ],
            ),
          ),
      ),
    );
  }

  Widget build_item(String value,IconData ic){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      child: Card(
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
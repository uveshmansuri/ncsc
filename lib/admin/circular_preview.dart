import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class circular_preview extends StatefulWidget{
  String title,description;
  circular_preview(this.title,this.description);

  @override
  State<circular_preview> createState() => _circular_previewState();
}

class _circular_previewState extends State<circular_preview> {
  String cname = "NARMADA COLLEGE OF SCIENCE & COMMERCE";
  String cloc = "Zadeshwar, Bharuch(Gujarat) 392011";
  String crr_date = DateFormat("dd.MM.yyyy").format(DateTime.now());

  bool isFacultySelected = false;
  bool isStaffSelected = false;
  bool isStudentSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Circular Preview"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Image.asset(
                              "assets/images/logo1.png", height: 200, width: 150,
                            )
                        ),
                        Text(
                          cname,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          cloc,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Date: $crr_date",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Divider(thickness: 1, height: 20),
                        Column(
                          children: [
                            Center(
                              child: Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Text(
                                widget.description,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text("Whome to Send",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isFacultySelected,
                        onChanged: (value) {
                          setState(() {
                            isFacultySelected = value!;
                          });
                        },
                      ),
                      Text("Faculty"),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isStaffSelected,
                        onChanged: (value) {
                          setState(() {
                            isStaffSelected = value!;
                          });
                        },
                      ),
                      Text("Staff"),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isStudentSelected,
                        onChanged: (value) {
                          setState(() {
                            isStudentSelected = value!;
                          });
                        },
                      ),
                      Text("Student"),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                alignment: Alignment.topRight,
                child: ElevatedButton.icon(onPressed: (){
                  if(isFacultySelected||isStudentSelected||isStaffSelected){
                    post_circular();
                  }else{
                    Fluttertoast.showToast(msg: "Select Receiver!!!");
                  }
                }, icon: Icon(Icons.send), label: Text("Send"),)
            ),
          ],
        ),
      ),
    );
  }
  
  void post_circular() async{
    final db_ref=await FirebaseDatabase.instance.ref("Circulars");
    db_ref.push().set({
      "title":widget.title,
      "description":widget.description,
      "published_date":crr_date,
      "faculty_rev":isFacultySelected,
      "staff_rev":isStaffSelected,
      "student_rev":isStudentSelected,
    }).then((_){
      Navigator.pop(context,true);
      Fluttertoast.showToast(msg: "Circular Sent Successfully");
    }).catchError((error){
      Fluttertoast.showToast(msg: "${error.toString()}");
    });
  }
}
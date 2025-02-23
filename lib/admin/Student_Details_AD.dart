import 'package:flutter/material.dart';

class Stud_AD extends StatefulWidget{
  var stud_id,sname,dept,sem,email;
  String? url;
  Stud_AD({required this.stud_id,required this.sname,required this.email,required this.dept,required this.sem,this.url});

  @override
  State<Stud_AD> createState() => _Stud_ADState();
}

class _Stud_ADState extends State<Stud_AD> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student's Detail"),
      ),
      body: Column(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(360),
              child:
              (widget.url != null && widget.url!.isNotEmpty)?
              Image.network(widget.url!, width: 50, height: 50, fit: BoxFit.cover)
                  :Image.asset("assets/images/student_profile.png",
                height: 50,
                width: 50,
                fit: BoxFit.fill,
              )
          ),
          //Text(widget.stud_id),
          Text(widget.sname),
          Text(widget.email),
          Text(widget.dept),
          Text(widget.sem),
        ],
      ),
    );
  }
  Widget content(String txt){
    return Row(
        children :[
          Text(txt),
        ]
    );
  }
}
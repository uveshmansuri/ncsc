import 'dart:async';
import 'package:NCSC/faculty/Tests_list.dart';
import 'package:NCSC/student/test.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TestScreen extends StatefulWidget {
  var stud_id;
  List<mcq_model> mcq_list;
  test_model test_obj;
  TestScreen({required this.stud_id,required this.mcq_list,required this.test_obj});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with WidgetsBindingObserver {
  int crr_question=0;
  int total_marks=0;
  int time_left=10;
  String? selected_op;
  Timer? timer;

  @override
  void initState() {
    time_left=int.parse(widget.test_obj.time_que);
    super.initState();
    start_timmer();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Fluttertoast.showToast(
        msg:  "Test Terminated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    } else if (state == AppLifecycleState.inactive) {
      Fluttertoast.showToast(
        msg:  "Test Terminated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void start_timmer(){
    timer=Timer.periodic(Duration(seconds: 1),(timer){
      if(time_left>0){
        setState(() {
          //print(time_left);
          time_left--;
        });
      }else{
        timer.cancel();
        _next();
      }
    });
  }

  void _next(){
    if(selected_op!.trim()==widget.mcq_list[crr_question].corr_op.replaceAll(RegExp(r'[`?]+$'), '')){
      total_marks++;
    }else{
      Fluttertoast.showToast(msg: widget.mcq_list[crr_question].corr_op);
    }
    crr_question++;
    if(crr_question<widget.mcq_list.length){
      setState(() {
        timer!.cancel();
        time_left=int.parse(widget.test_obj.time_que);
        start_timmer();
      });
    }else{
      Fluttertoast.showToast(msg: "Test Finished ${total_marks} out of ${widget.mcq_list.length}");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body:Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Time Left:$time_left"),
              Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Text("${crr_question+1}."),
                      title: Text("${widget.mcq_list[crr_question].quetion.replaceAll(RegExp(r'[?`]+$'), '')}"),
                    ),
                  )
              ),
              build_op_card(widget.mcq_list[crr_question].op1.toString()),
              build_op_card(widget.mcq_list[crr_question].op2.toString()),
              build_op_card(widget.mcq_list[crr_question].op3.toString()),
              build_op_card(widget.mcq_list[crr_question].op4.toString()),
              ElevatedButton(onPressed: _next, child: Text("Next")),
            ],
          ),
        ),
      ),
    );
  }

  Widget build_op_card(String op){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
      child: Card(
        elevation: 5,
        color: selected_op==op?Colors.blue:null,
        child: RadioListTile(
            title: Text("${op.trim()}",style: TextStyle(fontSize: 10,color: Colors.black,),),
            value: op.trim(),
            groupValue: selected_op,
            onChanged: (value){
              setState(() {
                selected_op=value as String;
              });
            }
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:NCSC/faculty/Tests_list.dart';
import 'package:NCSC/student/test.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
  String? selected_op="";
  Timer? timer;

  @override
  void initState() {
    time_left=int.parse(widget.test_obj.time_que);
    super.initState();
    start_timmer();
    selected_op=null;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      Fluttertoast.showToast(
        msg: "Test Terminated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.red,
        fontSize: 16.0,
      );
      Navigator.pop(context,false);
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
          time_left--;
        });
      }else{
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              duration: Duration(seconds: 1),
              content: AwesomeSnackbarContent(
                title: 'Oops! Time Up',
                message: "Correct Answer is "+widget.mcq_list[crr_question].corr_op.trim().replaceAll(RegExp(r'[`?]+$'), ''),
                contentType: ContentType.warning,
              ),
            )
        );
        Timer(Duration(seconds: 2), () {
          _next();
        });
      }
    });
  }

  void check(){
    if(selected_op==null){
      Fluttertoast.showToast(msg: "Select Option");
      return;
    }
    timer!.cancel();
    if(selected_op!.trim()==widget.mcq_list[crr_question].corr_op.trim().replaceAll(RegExp(r'[`?]+$'), '')){
      setState(() {
        total_marks++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            duration: Duration(seconds: 1),
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: "Answer is Correct",
              contentType: ContentType.success,
            ),
          )
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            duration: Duration(seconds: 1),
            content: AwesomeSnackbarContent(
              title: 'Oops! Wrong Answer',
              message: "Correct Answer is "+widget.mcq_list[crr_question].corr_op.trim().replaceAll(RegExp(r'[`?]+$'), ''),
              contentType: ContentType.failure,
            ),
          )
      );
      //Fluttertoast.showToast(msg: widget.mcq_list[crr_question].corr_op.trim().replaceAll(RegExp(r'[`?]+$'), ''));
    }
    Timer(Duration(seconds: 2), () {
      _next();
    });
  }

  void _next(){
    crr_question++;
    if(crr_question<widget.mcq_list.length){
      setState(() {
        selected_op=null;
        time_left=int.parse(widget.test_obj.time_que);
        start_timmer();
      });
    }else{
      // Fluttertoast.showToast(msg: "Test Finished ${total_marks} out of ${widget.mcq_list.length}");
      Navigator.pop(context,[total_marks,widget.mcq_list.length,true]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //time_line(),

            build_progress(),

            SizedBox(height: 15),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: time_left / (int.tryParse(widget.test_obj.time_que) ?? 10),
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
                Text(
                  "$time_left s",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              ],
            ),

            Text("$total_marks / ${widget.mcq_list.length}"),

            SizedBox(height: 15),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      "Q${crr_question + 1}: ${widget.mcq_list[crr_question].quetion}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    build_op_card(widget.mcq_list[crr_question].op1.toString()),
                    build_op_card(widget.mcq_list[crr_question].op2.toString()),
                    build_op_card(widget.mcq_list[crr_question].op3.toString()),
                    build_op_card(widget.mcq_list[crr_question].op4.toString()),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: check,
              child: Text("Next", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),

            SizedBox(height: 10),
          ],
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

  Widget build_progress(){
    var totalItems=widget.mcq_list.length;

    double progress = crr_question / totalItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$crr_question out of $totalItems",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          minHeight: 8,
        ),
      ],
    );
  }

  // Widget time_line(){
  //   return LayoutBuilder(
  //       builder: (context, constraints) {
  //         double availableWidth = constraints.maxWidth;
  //         double spacing = availableWidth / (widget.mcq_list.length * 2);
  //         return Wrap(
  //           alignment: WrapAlignment.start,
  //           spacing: spacing,
  //           runSpacing: 8.0, // Allows wrapping to the next line if needed
  //           children: List.generate(widget.mcq_list.length * 2 - 1, (index) {
  //             if (index.isEven) {
  //               int mcqIndex = index ~/ 2;
  //               bool isActive = mcqIndex == crr_question;
  //               bool isCompleted = mcqIndex < crr_question;
  //
  //               return CircleAvatar(
  //                 radius: 14,
  //                 backgroundColor:
  //                 isCompleted ? Colors.green : (isActive ? Colors.blue : Colors.grey),
  //                 child: Text(
  //                   '${mcqIndex + 1}',
  //                   style: TextStyle(color: Colors.white, fontSize: 12),
  //                 ),
  //               );
  //             } else {
  //               return SizedBox(
  //                 width: spacing,
  //                 child: Divider(
  //                   thickness: 4,
  //                   color: (index ~/ 2) < crr_question ? Colors.green : Colors.grey,
  //                 ),
  //               );
  //             }
  //           }),
  //         );
  //       }
  //   );
  // }
}
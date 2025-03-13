import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CreateTest2 extends StatefulWidget {
  var sub,dept,sem,fid,test_title;
  var topics;
  CreateTest2({required this.sem,required this.dept,required this.sub,required this.fid,required this.test_title,required this.topics});
  @override
  State<CreateTest2> createState() => _CreateTest2State();
}

class _CreateTest2State extends State<CreateTest2> {
  final TextEditingController _startDateTimeController = TextEditingController();
  final TextEditingController _endDateTimeController = TextEditingController();
  final TextEditingController _timePerQuestionController = TextEditingController();


  String? selectedLevel = "Easy";
  int? selectedQuestions = 10;
  DateTime? selectedStartDate;

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller, {DateTime? firstDate}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formattedDateTime = DateFormat("yyyy-MM-dd HH:mm").format(finalDateTime);
        controller.text = formattedDateTime;

        if (controller == _startDateTimeController) {
          setState(() {
            selectedStartDate = finalDateTime;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Subject:${widget.sub}",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Text("${widget.test_title}",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

            Divider(thickness: 1.5),

            Text(
              "Number of Questions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: selectedQuestions,
              items: [10, 20, 30].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value Questions"),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedQuestions = newValue;
                });
              },
            ),

            Divider(thickness: 1.5),
            SizedBox(height: 10),

            Text(
              "Select Difficulty Level:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: "Easy", label: Text("Easy")),
                ButtonSegment(value: "Medium", label: Text("Medium")),
                ButtonSegment(value: "Hard", label: Text("Hard")),
              ],
              selected: {selectedLevel!},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  selectedLevel = newSelection.first;
                });
              },
            ),

            SizedBox(height: 10),
            Divider(thickness: 1.5),
            SizedBox(height: 10),

            Text(
              "Test Schedule:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _selectDateTime(context, _startDateTimeController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _startDateTimeController,
                        decoration: InputDecoration(
                          labelText: "Start Date & Time",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (selectedStartDate != null) {
                        _selectDateTime(context, _endDateTimeController, firstDate: selectedStartDate!.add(Duration(minutes: 1)));
                      } else {
                        Fluttertoast.showToast(msg: "Select Start Date First");
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _endDateTimeController,
                        decoration: InputDecoration(
                          labelText: "End Date & Time",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            Divider(thickness: 1.5),
            SizedBox(height: 10),

            Text(
              "Time Per Question:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _timePerQuestionController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits (0-9)
                ],
                decoration: InputDecoration(
                  labelText: "Select Time (seconds)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if(_startDateTimeController.text.isEmpty||_endDateTimeController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Select Test Schedule Properly!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  if(_timePerQuestionController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please Select Time for Each Question'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  add_test();
                },
                child: Text("Save Test"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void add_test() async{
    var db_ref=FirebaseDatabase.instance.ref("Test").child(widget.dept).child(widget.sem);
    await db_ref
        .push()
        .set({
      "sub":widget.sub,
      "title":widget.test_title,
      "topics":widget.topics,
      "no_ques":selectedQuestions,
      "level":selectedLevel,
      "starting":_startDateTimeController.text,
      "ending":_endDateTimeController.text,
      "time_que":_timePerQuestionController.text
    })
        .then((_){
          Navigator.pop(context);
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Test Created");
    }).catchError((e){
      Fluttertoast.showToast(msg: "Error:${e.toString()}");
    });
  }
}

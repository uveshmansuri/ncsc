import 'package:NCSC/faculty/CreateTest_Meta_Data.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Createtest extends StatefulWidget {
  var sub,dept,sem,fid;
  Createtest({required this.sem,required this.dept,required this.sub,required this.fid});
  @override
  State<Createtest> createState() => _CreatetestState();
}

class _CreatetestState extends State<Createtest> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  List<String> topics = [];
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

  Future<void> _selectTimePerQuestion(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 10),
    );

    if (pickedTime != null) {
      int totalSeconds = (pickedTime.hour * 3600) + (pickedTime.minute * 60);
      _timePerQuestionController.text = "$totalSeconds seconds";
    }
  }

  void add_topic(){
    if(_topicController.text.trim().length==0){
      Fluttertoast.showToast(msg: "Please Enter Topic");
      return;
    }
    setState(() {
      topics.add(_topicController.text);
      _topicController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Test"),
      ),
      body: Column(
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Enter Test Title",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.title),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: _topicController,
                      decoration: InputDecoration(
                        labelText: "Enter Topic",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.topic),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: add_topic,
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(14),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(thickness: 1.5),
          SizedBox(height: 10),
          Text(
            "Topics Added:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(topics[index]),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          topics.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
                onPressed: (){
                  if(_titleController.text.isEmpty){
                    Fluttertoast.showToast(msg: "Enter Title of Test");
                    return;
                  }
                  if(topics.length>=5)
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context)=> CreateTest2(
                              sem: widget.sem, dept: widget.dept,
                              sub: widget.sub, fid: widget.fid,
                              test_title: _titleController.text,
                              topics: topics
                          )
                      )
                  );
                  else
                    Fluttertoast.showToast(msg: "Add Minimum 5 Topic");
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Next"),
                    Icon(Icons.navigate_next),
                  ],
                )
            ),
          )
        ],
      ),
    );
  }
}

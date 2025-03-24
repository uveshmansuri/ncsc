import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'Subject_List_Faculty.dart';

class Createschedulepage extends StatefulWidget {
  final String department;

  Createschedulepage({required this.department});

  @override
  State<Createschedulepage> createState() => _CreateschedulepageState();
}

class _CreateschedulepageState extends State<Createschedulepage> {
  List<TextEditingController> ed_list=[];

  TextEditingController ed1=TextEditingController();
  TextEditingController ed2=TextEditingController();
  TextEditingController ed3=TextEditingController();
  bool isLoading = true;

  bool is_generating=false;

  var is_check=false;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<subject> sub_list=[];

  @override
  void initState() {
    super.initState();
    fetch_subjects();
  }

  void fetch_subjects() async{
    var db=await FirebaseDatabase.instance.ref("Current_Sem").get();
    var crr_sem=db.value.toString();
    var c_sem=[];

    if(crr_sem=="Odd"){
      c_sem=["1","3","5"];
    }else{
      c_sem=["2","4","6"];
    }
    sub_list.clear();

    var db_ref=await FirebaseDatabase.instance.ref("Subjects").get();

    for(DataSnapshot sp in db_ref.children){

      if(sp.child("dept").value.toString()==widget.department){
        var sub,sid,dept,sem;
        sem=sp.child("sem").value.toString();
        if(c_sem.contains(sem)){
          sub=sp.child("name").value.toString();
          sid=sp.key;
          dept=sp.child("dept").value.toString();
          List<dynamic> assing_faculties = [];
          if(sp.child("ass_faculties").exists){
            assing_faculties.addAll(sp.child("ass_faculties").value as List<dynamic>);
          }

          List<String> ass_faculty_name=[];
          for(var fid in assing_faculties){
            var db=await FirebaseDatabase.instance.ref("Staff/faculty/$fid/name").get();
            var _ctr=TextEditingController();
            ass_faculty_name.add(db.value.toString());
            ed_list.add(_ctr);
          }
          sub_list.add(subject(sid, sub, ass_faculty_name, dept, sem));
        }
      }
    }

    setState(() {
      isLoading=false;
    });
  }

  // void fetchFacultyNames() async {
  //   DatabaseReference ref = FirebaseDatabase.instance.ref("faculty");
  //   DatabaseEvent event = await ref.once();
  //   DataSnapshot snapshot = event.snapshot;
  //
  //   Map<String, String> tempFacultyMap = {};
  //
  //   for (DataSnapshot sp in snapshot.children) {
  //     String fid = sp.key.toString();
  //     String name = sp.child("name").value.toString();
  //
  //     tempFacultyMap[fid] = name;
  //   }
  //
  //   setState(() {
  //     facultyMap = tempFacultyMap;
  //   });
  //
  //   fetchSubjects();
  // }
  // void fetchSubjects() async {
  //   DatabaseReference ref = FirebaseDatabase.instance.ref("Subjects");
  //   DatabaseEvent event = await ref.once();
  //   DataSnapshot snapshot = event.snapshot;
  //
  //   List<Map<String, String>> tempList = [];
  //
  //   for (DataSnapshot sp in snapshot.children) {
  //     if (sp.child("dept").value.toString() == widget.department) {
  //       String subjectName = sp.child("name").value.toString();
  //       String semester = sp.child("sem").value.toString();
  //       String facultyId = sp.child("ass_faculties").value.toString().trim();
  //
  //       tempList.add({
  //         "subject": subjectName,
  //         "semester": semester,
  //         "facultyId": facultyId,
  //         "faculty": facultyMap.containsKey(facultyId) ? facultyMap[facultyId]! : "Unknown", // Assign correct name
  //       });
  //
  //       controllers[subjectName] = TextEditingController();
  //     }
  //   }
  //
  //   setState(() {
  //     subjectList = tempList;
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subjects for ${widget.department}")),
      body: isLoading
          ?
      Center(child: CircularProgressIndicator())
          :
      sub_list.isEmpty
          ?
      Center(child: Text("No subjects available"))
          :
      Stack(
        children: [
          Column(
            children: [
              Column(
                children: [
                  ListTile(
                    title: Text(startTime != null
                        ? "Start Time: ${startTime!.format(context)}"
                        : "Pick Start Time"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context, true),
                  ),
                  ListTile(
                    title: Text(endTime != null
                        ? "End Time: ${endTime!.format(context)}"
                        : "Pick End Time"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context, false),
                  ),
                ],
              ),

              Expanded(
                flex: 9,
                child: ListView.builder(
                  itemCount: sub_list.length,
                  itemBuilder: (context, index) {
                    String subjectName = sub_list[index].sname!;
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Subject: ${sub_list[index].sname!}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Semester: ${sub_list[index].sem!}"),
                            Text("Faculty: ${sub_list[index].fid.join(",")}"),
                            SizedBox(height: 10),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: ed_list[index],
                              decoration: InputDecoration(
                                label: Text("Enter Slots per Weak"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Expanded(
              //   flex: 2,
              //     child: SingleChildScrollView(
              //       child: Column(
              //         children: [
              //           Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Text("Lab is Avilable?"),
              //               Checkbox(
              //                   value: is_check,
              //                   onChanged: (value){
              //                     setState(() {
              //                       is_check=value!;
              //                     });
              //                   }
              //               ),
              //             ],
              //           ),
              //           if(is_check)
              //             Padding(
              //               padding: const EdgeInsets.symmetric(horizontal: 18),
              //               child: Column(
              //                 children: [
              //                   TextField(
              //                     keyboardType: TextInputType.number,
              //                     controller: ed1,
              //                     decoration: InputDecoration(
              //                       label: Text("Enter Lab Slot per day for Sem1"),
              //                     ),
              //                   ),
              //                   SizedBox(height: 10,),
              //                   TextField(
              //                     keyboardType: TextInputType.number,
              //                     controller: ed2,
              //                     decoration: InputDecoration(
              //                       label: Text("Enter Lab Slot per day for Sem3"),
              //                     ),
              //                   ),
              //                   SizedBox(height: 10,),
              //                   TextField(
              //                     keyboardType: TextInputType.number,
              //                     controller: ed3,
              //                     decoration: InputDecoration(
              //                       label: Text("Enter Lab Slot per day for Sem5"),
              //                     ),
              //                   ),
              //                   SizedBox(height: 10,),
              //                 ],
              //               ),
              //             ),
              //         ],
              //       ),
              //     )
              // ),
            ],
          ),
          if(is_generating==true)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "Generating Time Table",
                        style: TextStyle(
                            fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showTimePickerDialog();
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _showTimePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Start & End Time"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(startTime != null
                    ? "Start Time: ${startTime!.format(context)}"
                    : "Pick Start Time"),
                trailing: const Icon(Icons.access_time),
              ),
              ListTile(
                title: Text(endTime != null
                    ? "End Time: ${endTime!.format(context)}"
                    : "Pick End Time"),
                trailing: const Icon(Icons.access_time),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                genrate_timetable();
                // You can use startTime and endTime here as needed
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void genrate_timetable() async{

    var subject_details=[];
    print(sub_list.length);
    for(int i=0;i<sub_list.length;i++){
     var temp =("Subject:${sub_list[i].sname},Semester:${sub_list[i].sem},"
         "Faculty:${sub_list[i].fid.join(",")},"
         "Sessions per weak:${ed_list[i]!.text}");
     subject_details.add(temp);
    }

    // String prompt="Generate a weekly timetable for the following subjects, their assigned faculty, and the required number "
    //     "of sessions per week. The timetable should be structured as: time -> semester -> {subject, faculty}. Ensure that "
    //     "no faculty member is scheduled to teach multiple subjects simultaneously Here is the subject details ${subject_details}"
    //     "and starting of day is 11:00 AM and ends at 4:00 PM"
    //     "Please generate the timetable accordingly. also don't add any extra info give only Json format data that i can store "
    //     "in json like given formate day of weak->time->sem [1,3,5] -> {free or 'subject,faculty'} here free if no class their"
    //     "also generate json file compleately and for weak days from monday to saturday";

    // String prompt="Generate a weekly timetable for the following subjects,"
    //     " their assigned faculty, and the required number of sessions per week. "
    //     "The timetable should be structured as: time -> semester -> {subject, faculty}. Ensure that no faculty "
    //     "member is scheduled to teach multiple subjects simultaneously"
    //     "Here is the subject details ${subject_details}"
    //     "and starting of day is $startTime and ends at $endTime"+
    //     "Please generate the timetable accordingly. also don't add any extra info."
    //     " give only Json format data that i can store in json like "
    //     " given formate day of weak->time->sem [1,3,5] -> {free or subject:faculty} here free if no class their"
    //     " also generate json file compleately and for weak days from monday to saturday";

    String pr='''
    Generate a weekly timetable in JSON format with the following requirements:
                        Timetable Structure:
                        -Time table cvers monday to saturday
                        -Each day consists of Time slots from  $startTime to $endTime.
                        -Each Time sloat contains schedule for 3 grops sem1,sem2,sem3.
                        -If sloat has no schedule then it should be marks as "free"
                        -Also arange subjects and time slot properly and each session must be 1 hour long
                        -Also add half hour break to each semester every  
                        day (e.g., [1, 3, 5]) to either "free" or "lab" or "break" or a string formatted as "subject, faculty                       
                        -Each subject assing to faculty member represent by initial ex(Uv for Uvesh)
                        -Use the provided variable ${subject_details}, which contains the subjects, their assigned faculty, 
                        and the required number of sessions per week.
                         Constraints:
                        - Ensure no faculty member is scheduled to teach more than one subject simultaneously.    
                        Important Note:
                        -Guarantee that every day has classes scheduled for each semester ensure that 
                        no day is completely free and that the daily workload is approximately equal.
                        -And properly initialize slots for subjects per weak for each semester                                            
                        
                        Output only the JSON data without any extra information.              
    ''';

    String prompt = """Generate a weekly timetable in JSON format with the following requirements:
                        Timetable Structure:
                        - Keys: Day of week (Monday to Saturday).
                        - Nested keys: Time slots from $startTime to $endTime.
                        - Values: An object mapping semester numbers (e.g., [1, 3, 5]) to either "free" or a string formatted as 
                        "subject, faculty".                                        
                        Subject Details:
                        Use the provided variable ${subject_details}, which contains the subjects, their assigned faculty, 
                        and the required number of sessions per week.
                        
                        Constraints:
                        - Ensure no faculty member is scheduled to teach more than one subject simultaneously.
                        - Populate each time slot for each semester accordingly, marking it as "free" if no class is scheduled.
                        - Also arange subjects and time slot properly without messing up and each session must be 1 hour long
                        - Also consider that required number of sessions per week for ecah subject of semester
                        - Also add half hour break to each semester every  day (e.g., [1, 3, 5]) to either "free" or "lab" or "break" or a string formatted as "subject, faculty                       
                       
                        Important Note:
                        -Guarantee that every day has classes scheduled for each semester ensure that 
                        no day is completely free and that the daily workload is approximately equal.
                        -And properly initialize slots for subjects per weak for each semester                                            
                        
                        Output only the JSON data without any extra information.""";


    var key="AIzaSyC9KMLHWS9IBy3ZqRTuarkbA1L085JxWcQ";
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: key);
    final content = [Content.text(prompt)];

    setState(() {
      is_generating=true;
    });
    final response = await model.generateContent(content);

    var res=response.text;
    if (res!.startsWith('```json')) {
      res = res!.replaceFirst('```json', '');
    }

    // Remove ``` from the end
    if (res.endsWith('```')) {
      res = res!.replaceFirst(RegExp(r'```$'), '');
    }
    debugPrint(res);
    try{
      setState(() {
        is_generating=false;
      });
      jsonDecode(res);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>timetable_preview(timtable_data: res!.trim())));
    }catch(ex){
      setState(() {
        is_generating=false;
      });
      print(ex.toString());
    }
  }
}

class timetable_preview extends StatelessWidget{
  final String timtable_data;
  timetable_preview({required this.timtable_data});
  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> timetable = jsonDecode(timtable_data);

    return Scaffold(
      appBar: AppBar(title: Text("Timetable")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: timetable.keys.map((day) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FixedColumnWidth(80.0),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: [
                        _tableCell("Time", isHeader: true),
                        _tableCell("Semester 1", isHeader: true),
                        _tableCell("Semester 3", isHeader: true),
                        _tableCell("Semester 5", isHeader: true),
                      ],
                    ),
                    // Table Rows
                    ...timetable[day].entries.map((entry) {
                      String time = entry.key;
                      Map<String, dynamic> batches = entry.value;
                      return TableRow(children: [
                        _tableCell(time),
                        _tableCell(batches["1"] ?? "-"),
                        _tableCell(batches["3"] ?? "-"),
                        _tableCell(batches["5"] ?? "-"),
                      ]);
                    }).toList(),
                  ],
                ),
                SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 16 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
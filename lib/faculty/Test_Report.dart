import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class test_report_model {
  var stud_id, name, result;
  test_report_model({required this.stud_id, required this.name, required this.result});
}

class TestReportScreen extends StatefulWidget {
  final String dept;
  final String sem;
  final String test_id;

  TestReportScreen({required this.dept, required this.sem, required this.test_id});

  @override
  _TestReportScreenState createState() => _TestReportScreenState();
}

class _TestReportScreenState extends State<TestReportScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  List<test_report_model> studentReport = [];

  List<Map<String,String>> students=[];

  var total_students=0;
  var attempted=0;
  var terminated=0;

  bool get_details_flag=false;

  @override
  void initState() {
    super.initState();
    fetch_report();
  }

  void fetch_report() async{
    var dbref1=await FirebaseDatabase.instance.ref("Students").get();
    for(DataSnapshot sp in dbref1.children){
      if(sp.child("dept").value.toString()==widget.dept && sp.child("sem").value.toString()==widget.sem){
        //students.add({sp.key.toString():sp.child("name").value.toString()});
        studentReport.add(
            test_report_model(
                stud_id: sp.key.toString(), name: sp.child("name").value.toString(), result: "Not Attempted"
            )
        );
        total_students++;
      }
    }
    await FirebaseDatabase.instance
        .ref("Test/${widget.dept}/${widget.sem}/${widget.test_id}/Report")
        .onChildAdded.listen((event){
          for(var obj in studentReport){
            if(obj.stud_id==event.snapshot.key){
              attempted++;
              obj.result=event.snapshot.child("result").value.toString();
              if(obj.result=="Terminated"){
                terminated++;
              }
              setState(() {
                get_details_flag=true;
              });
            }
          }
        });
    setState(() {
      get_details_flag=true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Report (${widget.dept} Sem ${widget.sem})"),
        actions: [
          IconButton(onPressed: show_summery, icon: Icon(Icons.summarize))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          get_details_flag==true?Expanded(
            child: ListView.builder(
              itemCount: studentReport.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  color: get_Color(index),
                  child: ListTile(
                    title: Text(studentReport[index].name),
                    subtitle: Text(studentReport[index].stud_id),
                    trailing: Text(studentReport[index].result),
                  ),
                );
              },
            ),
          )
              :
          Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  Color get_Color(int i){
    if(studentReport[i].result=="Not Attempted"){
      return Color(0x91FFFB00);
    }
    else if(studentReport[i].result=="Terminated"){
      return Colors.redAccent;
    }
    else{
      return Colors.greenAccent;
    }
  }

  void show_summery() {
    int remaining = total_students - (attempted + terminated);
    int finished=attempted-terminated;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Summary"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: finished.toDouble(),
                        title: '',
                        color: Colors.green,
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: terminated.toDouble(),
                        title: '',
                        color: Colors.red,
                        radius: 60,
                      ),
                      PieChartSectionData(
                        value: remaining.toDouble(),
                        title: '',
                        color: Color(0x91FFFB00),
                        radius: 60,
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildLegend(Colors.green, 'Finished:$finished'),
              const SizedBox(height: 10),
              _buildLegend(Colors.red, 'Terminated:$terminated'),
              const SizedBox(height: 10),
              _buildLegend(Color(0x91FFFB00), 'Remaining:$remaining'),
              const SizedBox(height: 20),
              Center(
                child: Text("Total Students Attempted:${attempted}"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text("$label"),
      ],
    );
  }
}
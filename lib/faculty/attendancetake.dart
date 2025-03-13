import 'dart:io';
import 'package:NCSC/faculty/LiveFeed_Attend.dart';
import 'package:NCSC/faculty/Live_Feed_Web.dart';
import 'package:NCSC/faculty/mark_attendance.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  var dept,sem,sub;
  AttendancePage(this.dept,this.sem,this.sub);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<students> stud_list=[];

  int total_class=0;

  @override
  void initState() {
    // TODO: implement initState
    fect_students();
    super.initState();
  }

  void fect_students() async{

    var db_ref=await FirebaseDatabase.instance.ref("Students").get();

    var db_ref2=FirebaseDatabase.instance.ref("Attendance").child(widget.sub);
    var sp2=await db_ref2.get();
    if(sp2.exists)
      total_class=sp2.children.length;

    for(DataSnapshot sp in db_ref.children){
      if(sp.child("dept").value.toString()==widget.dept&&sp.child("sem").value.toString()==widget.sem){
        int class_count=0;
        double pr=0.0;
        if(sp2.exists){
          for(DataSnapshot s in sp2.children){
            for (DataSnapshot s1 in s.children){
              if(s1.key==sp.key && s1.child("status").value.toString()=="P"){
                class_count++;
              }
            }
          }
          pr=(class_count*100)/total_class;
        }

        if(sp.child("encoding").exists){
          List<dynamic> encodings = List<dynamic>.from(sp.child("encoding").value as List);
          //print("Name: ${sp.child("name").value.toString()} ${encodings.length}");
          stud_list.add(students(
              stud_id: sp.key,
              stud_name: sp.child("name").value.toString(),
              encodings: encodings,
              atten_pr:pr
          ));
        }else{
          stud_list.add(students(
              stud_id: sp.key, 
              stud_name: sp.child("name").value.toString(),
              atten_pr:pr
          ));
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.sub} Attendance")),
      body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Card(
                  elevation: 5,
                  shadowColor: Colors.lightBlueAccent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Student Id",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                        Text("Student Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                        Text("Attendance Pr(%)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListView.builder(
                        itemCount: stud_list.length,
                        itemBuilder: (context,i){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
                            child: Card(
                              elevation: 3,
                              shadowColor: Colors.lightBlueAccent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        flex:4,
                                        child: Text(stud_list[i].stud_id)
                                    ),
                                    Expanded(
                                        flex:5,
                                        child: Text(stud_list[i].stud_name)
                                    ),
                                    Expanded(
                                        flex:3,
                                        child: Text("${stud_list[i].atten_pr?.toStringAsFixed(2)}%")
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  )
              ),
              Card(
                elevation: 5,
                shadowColor: Colors.lightBlueAccent,
                child: TextButton.icon(
                    icon: Icon(Icons.assignment_turned_in_outlined),
                    onPressed: () async{
                      String crr_date = DateFormat("dd-MM-yyyy-HH-mm").format(DateTime.now());
                      var sp=await FirebaseDatabase.instance.ref("Attendance").child(widget.sub).child(crr_date).get();
                      if(sp.exists){
                        Fluttertoast.showToast(msg: "You can Take Attendance After One Hour");
                      }else{
                        show_dig(crr_date);
                      }
                    },
                    label: Text("Take Attendance")
                ),
              ),
              Card(
                elevation: 5,
                shadowColor: Colors.lightBlueAccent,
                child: TextButton.icon(
                  onPressed: () async{
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>attend_sheet(widget.dept, widget.sem, widget.sub))
                    );
                  },
                  label: Text("View AttendanceSheet"),
                  icon: Icon(Icons.preview),
                ),
              ),
              SizedBox(height: 10,)
            ],
          )
      ),
    );
  }

  void show_dig(String crr_date){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Confirm Session"),
        content: Text("Do you want to take attendance of "
            "\n${widget.dept} Semester:${widget.sem} Subject:${widget.sub}"
            "\nDate:$crr_date"
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
                if(kIsWeb){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context)=>
                              Live_feed_web(widget.dept,widget.sem,widget.sub,stud_list)
                      )
                  );
                }else{
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context)=>
                              Live_Attend(widget.dept,widget.sem,widget.sub,stud_list)
                      )
                  );
                }

              }, child: Text("Auto")),
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        mark_attend(widget.dept, widget.sem, widget.sub,stud_list)
                    ));
              }, child: Text("Manually")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Cancel")),
            ],
          ),
        ],
      );
    });
  }
}

class students{
  var stud_id,stud_name;
  double? atten_pr;
  List<dynamic>? encodings;
  Map<dynamic,dynamic>? attend;
  students({required this.stud_id, required this.stud_name, this.encodings,this.atten_pr,this.attend});
}

class attend_sheet extends StatefulWidget{
  var dept,sem,sub;
  attend_sheet(this.dept,this.sem,this.sub);
  @override
  State<attend_sheet> createState() => _attend_sheetState();
}

class _attend_sheetState extends State<attend_sheet> {
  List<students> Records=[];
  int total_class=0;
  Map<String,int> sum={};
  int total_students=0;

  bool flag=true;

  final ScrollController _horizontalController = ScrollController();
  //final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    get_attennd_data();
    get_sammary();
  }

  void get_attennd_data() async{
    var snap_stud=await FirebaseDatabase.instance.ref("Students").get();
    var snap_attend=await FirebaseDatabase.instance.ref("Attendance/${widget.sub}").get();

    int total_class=snap_attend.children.length;

    for(DataSnapshot sp1 in snap_stud.children){
      if(sp1.child("dept").value.toString()==widget.dept&&sp1.child("sem").value.toString()==widget.sem){
        Map<dynamic,dynamic> attend={};
        var name=(sp1.child("name").value.toString());
        int class_count=0;
        double pr=0.0;
        if (snap_attend.exists) {
          List<String> sessionKeys = snap_attend.children
              .map((s) => s.key.toString())
              .toList();
          sessionKeys.sort((a, b) {
            DateTime dateA = parseDateTime(a);
            DateTime dateB = parseDateTime(b);
            return dateA.compareTo(dateB);
          });

          for (String session in sessionKeys) {
            var status = "E";
            DataSnapshot? s = snap_attend.child(session);

            for (DataSnapshot s1 in s.children) {
              if (s1.key == sp1.key) {
                if (s1.child("status").value.toString() == "P") {
                  class_count++;
                }
                status = s1.child("status").value.toString();
              }
            }
            attend[session] = status;
          }
        }
        pr=(class_count*100)/total_class;
        Records.add(students(stud_id: sp1.key, stud_name: name , attend: attend,atten_pr: pr));
        setState(() {
          flag=false;
        });
      }
    }
  }

  void get_sammary() async{
    final stud_ref=FirebaseDatabase.instance.ref("Students");
    final query=stud_ref.orderByChild("dept").equalTo(widget.dept);
    query.once().then((event){
      final sp=event.snapshot;
      for(var s1 in sp.children){
        if(s1.child("sem").value.toString()=="5"){
          total_students++;
        }
      }
      setState(() {

      });
    });
    var snap_attend=await FirebaseDatabase.instance.ref("Attendance/${widget.sub}").get();
    if(snap_attend.exists){
      for(DataSnapshot sp in snap_attend.children){
        int total_stud=0;
        for(DataSnapshot s1 in sp.children){
          if(s1.child("status").value.toString()=="P"){
            total_stud+=1;
          }
        }
        sum[sp.key.toString()]=total_stud;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> allDates = (Records
        .expand((record) => record.attend!.keys)
        .toSet()
        .toList()).cast<String>();
    return Scaffold(
      appBar: AppBar(title: Text('${widget.sub} Attendance Sheet')),
      body: Stack(
        children: [
          flag==true
              ?
          Center(
            child: CircularProgressIndicator(),
          )
              :
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 12,
                    horizontalMargin: 10,
                    headingRowColor: MaterialStateProperty.all(Colors.lightBlue[200]),
                    border: TableBorder.all(color: Colors.black, width: 2),

                    columns: [
                      DataColumn(label: Text('Student ID',style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Student Name',style: TextStyle(fontWeight: FontWeight.bold))),
                      ...allDates.map((date) => DataColumn(
                          label: Text(date,style: TextStyle(fontWeight: FontWeight.bold))
                      )).toList(),
                      DataColumn(label: Text("Percentage",style: TextStyle(fontWeight: FontWeight.bold))),
                    ],

                    rows: Records.map((record) {
                      bool isLowAttendance = record.atten_pr! < 50;
                      return DataRow(
                        color: isLowAttendance
                            ? MaterialStateProperty.all(Colors.red.withOpacity(0.2))
                            : null,
                        cells: [
                          DataCell(Text(record.stud_id)),
                          DataCell(Text(record.stud_name)),
                          ...allDates.map((date) {
                            String status = record.attend?[date] ?? '-';
                            return DataCell(
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(status),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          DataCell(Text("${record.atten_pr!.toStringAsFixed(2)}%",
                              style: TextStyle(fontWeight: FontWeight.bold, color: record.atten_pr! < 50 ? Colors.red : Colors.green)
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _exportToExcel,
            child: Icon(Icons.download,color: Colors.red,),
          ),
          SizedBox(height: 10,),
          FloatingActionButton(
            onPressed: ()=>showAttendanceLineChart(context,sum),
            child: Icon(Icons.show_chart_rounded,color: Colors.blue,),
          ),
        ],
      )
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'P':
        return Colors.green;
      case 'A':
        return Colors.red;
      case 'E':
        return Colors.yellow;
      default:
        return Colors.grey[300]!; 
    }
  }

  DateTime parseDateTime(String dateStr) {
    List<String> parts = dateStr.split('-'); // Split by '-'

    if (parts.length < 4) {
      return DateTime(1970); // Return default for invalid data
    }

    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    int hour = int.parse(parts[3]);

    return DateTime(year, month, day, hour);
  }

  void _exportToExcel() async {
    List<String> allDates = (Records
        .expand((record) => record.attend!.keys)
        .toSet()
        .toList()).cast<String>();

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    List<String> headers = ['Student ID', 'Student Name', ...allDates, 'Percentage'];
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    for (var record in Records) {
      List<CellValue> row = [
        TextCellValue(record.stud_id),
        TextCellValue(record.stud_name),
        ...allDates.map((date) => TextCellValue(record.attend?[date] ?? '-')),
        TextCellValue("${record.atten_pr!.toStringAsFixed(2)}%"),
      ];
      sheet.appendRow(row);
    }

    List<int>? excelBytes = excel.encode();
    if (excelBytes == null) return;

    if (kIsWeb) {
      var obj=Live_feed_web(widget.dept, widget.sem, widget.sub,Records);
      obj.export_excel_file_web(excelBytes);
    }
    else {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        Directory? directory = await getExternalStorageDirectory();
        String filePath = "${directory!.path}/${widget.sub} AttendanceSheet.xlsx";
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excelBytes);
        Fluttertoast.showToast(msg: "Excel file saved at: $filePath");
      } else {
        Fluttertoast.showToast(msg:"Storage permission denied");
      }
    }
  }

  Future<void> showAttendanceLineChart(BuildContext context, Map<String, int> dataMap) async {
    List<String> sorted_dates=dataMap.keys.toList()..sort();

    List<FlSpot> spots=[];
    for(int i=0;i<sorted_dates.length;i++){
      String date=sorted_dates[i];
      int yval=dataMap[date]!;
      spots.add(FlSpot(i.toDouble(), yval.toDouble()));
    }

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Attendance'),
          content: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: total_students.toDouble()+5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                    barWidth: 2,
                    isStrokeCapRound: true,
                  ),
                ],
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles:  AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      )
                  ),
                  topTitles:  AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      )
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('${value.toInt()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      interval: 10
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < sorted_dates.length) {
                          return Transform.rotate(
                            angle: -0.90,
                            child: Text(
                              sorted_dates[index],
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          );
                        }
                        return Container();
                      },
                      interval: 1,
                    ),
                  ),
                ),

              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
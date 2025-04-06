import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TimetablePage extends StatefulWidget {
  var crr_sem,dept;
  TimetablePage({this.dept, this.crr_sem});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final DatabaseReference _timetableRef = FirebaseDatabase.instance.ref("department");
  Map<dynamic, dynamic> _timetableData = {};

  bool is_loading=true;
  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  // Fetch timetable data from Firebase
  Future<void> _fetchTimetable() async {
    final snapshot = await _timetableRef.get();
    for(DataSnapshot sp in snapshot.children){
      if(sp.child("department").value.toString()==widget.dept){
        if(sp.child("timetable").exists){
          setState(() {
            _timetableData = sp.child("timetable").value as Map<dynamic, dynamic>;
            is_loading=false;
          });
        }else{
          setState(() {
            is_loading=false;
          });
        }
        break;
      }
    }
  }

  // Return the appropriate schedule based on the current semester
  String getScheduleForTimeSlot(Map<dynamic, dynamic> timeslotData) {
    if (widget.crr_sem == "1"|| widget.crr_sem == "2") {
      return timeslotData['FY'] ?? "";
    } else if (widget.crr_sem == "3" || widget.crr_sem == "4") {
      return timeslotData['SY'] ?? "";
    } else if (widget.crr_sem == "5" || widget.crr_sem == "6") {
      return timeslotData['TY'] ?? "";
    }
    return "";
  }
  @override
  Widget build(BuildContext context) {
    // Define the week days order
    final List<String> weekDaysOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    // Extract the day names from the map
    List<String> days = _timetableData.keys.cast<String>().toList();
    // Sort days by week order; if a day is not in weekDaysOrder, it gets a high index
    days.sort((a, b) {
      int indexA = weekDaysOrder.contains(a) ? weekDaysOrder.indexOf(a) : 999;
      int indexB = weekDaysOrder.contains(b) ? weekDaysOrder.indexOf(b) : 999;
      return indexA.compareTo(indexB);
    });

    // Compute the union of all time slot keys across days
    Set<String> timeSlotSet = {};
    _timetableData.forEach((day, dayData) {
      if (dayData is Map) {
        timeSlotSet.addAll(dayData.keys.cast<String>());
      }
    });
    // Convert to list and sort (assuming the time format allows lexical sorting)
    List<String> timeSlots = timeSlotSet.toList()..sort();

    // Set a fixed width for each cell
    const double cellWidth = 100;

    // Build DataTable columns: one for time slot and one per day
    List<DataColumn> columns = [
      DataColumn(
          label: Container(
            width: cellWidth,
            child: Text(
              "Time Slot",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
              ),
              softWrap: true,
            ),
          )),
      ...days.map((day) => DataColumn(
        label: Container(
          width: cellWidth,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 17
            ),
            softWrap: true,
          ),
        ),
      )),
    ];

    // Build DataTable rows: each row for a time slot
    List<DataRow> rows = timeSlots.map((timeSlot) {
      // First cell is the time slot label
      List<DataCell> cells = [
        DataCell(
          Container(
            width: cellWidth,
            child: Text(
              timeSlot,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
              ),
              softWrap: true,
            ),
          ),
        ),
      ];
      // Create a cell for each day
      for (var day in days) {
        String schedule = "";
        if (_timetableData[day] is Map &&
            (_timetableData[day] as Map).containsKey(timeSlot)) {
          Map<dynamic, dynamic> timeslotData =
          (_timetableData[day] as Map)[timeSlot];
          schedule = getScheduleForTimeSlot(timeslotData);
        }
        cells.add(
          DataCell(
            Container(
              width: cellWidth,
              child: Text(
                schedule,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
                softWrap: true,
              ),
            ),
          ),
        );
      }
      return DataRow(cells: cells);
    }).toList();
    return Scaffold(
      backgroundColor: Colors.tealAccent.shade100,
      appBar: AppBar(
        title: Text("Timetable"),
        backgroundColor: Colors.tealAccent,
      ),
      body: is_loading
          ? Center(child: CircularProgressIndicator())
          : _timetableData.isEmpty
          ? Center(child: const Text("Timetable is not published yet",style: TextStyle(color: Colors.black,fontSize: 20),),)
          : Padding(
        padding: const EdgeInsets.all(0),
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey, width: 2),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: columns,
                rows: rows,
                headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Color(0xFFCEFFFF)),
                dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Color(0xFFB9FFD6)),
                columnSpacing: 20,
                dataRowHeight: 60,
                headingRowHeight: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
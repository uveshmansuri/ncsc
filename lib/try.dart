import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EnhancedAttendancePage extends StatefulWidget {
  @override
  _EnhancedAttendancePageState createState() => _EnhancedAttendancePageState();
}

class _EnhancedAttendancePageState extends State<EnhancedAttendancePage> {
  final List<String> roles = ["Students", "Teachers", "Non-Teaching Staff"];
  String selectedRole = "Students";

  final int attendanceThreshold = 75;

  final Map<String, List<Map<String, dynamic>>> attendanceData = {
    "Students": [
      {"id": "S001", "name": "John Doe", "presentDays": 75, "totalDays": 100},
      {"id": "S002", "name": "Jane Smith", "presentDays": 50, "totalDays": 100},
    ],
    "Teachers": [
      {"id": "T001", "name": "Mr. Sharma", "presentDays": 180, "totalDays": 200},
      {"id": "T002", "name": "Ms. Priya", "presentDays": 190, "totalDays": 200},
    ],
    "Non-Teaching Staff": [
      {"id": "N001", "name": "Ramesh Kumar", "presentDays": 100, "totalDays": 150},
      {"id": "N002", "name": "Sita Devi", "presentDays": 140, "totalDays": 150},
    ],
  };

  List<Map<String, dynamic>> get filteredData =>
      attendanceData[selectedRole]!;

  List<PieChartSectionData> _createPieChartData() {
    final data = filteredData.map((person) {
      final attendancePercentage =
      (person['presentDays'] / person['totalDays'] * 100).toDouble();
      return {
        'id': person['id'],
        'name': person['name'],
        'percentage': attendancePercentage,
        'status': attendancePercentage >= attendanceThreshold ? 'Good' : 'Low',
      };
    }).toList();

    final goodCount = data.where((d) => d['status'] == 'Good').length;
    final lowCount = data.where((d) => d['status'] == 'Low').length;

    return [
      PieChartSectionData(
        value: goodCount.toDouble(),
        title: 'Good',
        color: Colors.green,
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: lowCount.toDouble(),
        title: 'Low',
        color: Colors.red,
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ];
  }

  void _modifyAttendance(Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (context) {
        final presentDaysController =
        TextEditingController(text: person['presentDays'].toString());
        final totalDaysController =
        TextEditingController(text: person['totalDays'].toString());

        return AlertDialog(
          title: Text('Modify Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: presentDaysController,
                decoration: InputDecoration(labelText: 'Present Days'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: totalDaysController,
                decoration: InputDecoration(labelText: 'Total Days'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  person['presentDays'] =
                      int.parse(presentDaysController.text);
                  person['totalDays'] = int.parse(totalDaysController.text);
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced Attendance Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (newRole) {
                setState(() {
                  selectedRole = newRole!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Role',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _createPieChartData(),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final person = filteredData[index];
                  final percentage = (person['presentDays'] /
                      person['totalDays'] *
                      100)
                      .toStringAsFixed(2);

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(person['name']),
                      subtitle: Text(
                          'Attendance: $percentage% (${person['presentDays']}/${person['totalDays']})'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _modifyAttendance(person),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

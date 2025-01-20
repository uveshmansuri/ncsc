import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for attendance
  final List<Map<String, dynamic>> facultyAttendance = [
    {'name': 'Dr. John Doe', 'department': 'Computer Science', 'present': 90, 'absent': 10},
    {'name': 'Dr. Jane Smith', 'department': 'Mathematics', 'present': 85, 'absent': 15},
  ];

  final List<Map<String, dynamic>> staffAttendance = [
    {'name': 'Mr. Alan Walker', 'present': 80, 'absent': 20},
    {'name': 'Ms. Lucy Grey', 'present': 95, 'absent': 5},
  ];

  final List<Map<String, dynamic>> studentAttendance = [
    {'name': 'John Adams', 'dept': 'CS', 'class': 'CS101', 'present': 75, 'absent': 25},
    {'name': 'Mary Johnson', 'dept': 'IT', 'class': 'IT201', 'present': 90, 'absent': 10},
  ];

  String selectedDept = 'CS'; // Default department for students
  String selectedClass = 'CS101'; // Default class for students

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Faculty'),
            Tab(text: 'Staff'),
            Tab(text: 'Students'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFacultyAttendance(),
          _buildStaffAttendance(),
          _buildStudentAttendance(),
        ],
      ),
    );
  }

  // Faculty Attendance
  Widget _buildFacultyAttendance() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: facultyAttendance
          .map(
            (faculty) => Card(
          child: ListTile(
            title: Text(faculty['name']),
            subtitle: Text('Department: ${faculty['department']}'),
            trailing: _buildAttendanceBar(faculty['present'], faculty['absent']),
          ),
        ),
      )
          .toList(),
    );
  }

  // Staff Attendance
  Widget _buildStaffAttendance() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: staffAttendance
          .map(
            (staff) => Card(
          child: ListTile(
            title: Text(staff['name']),
            trailing: _buildAttendanceBar(staff['present'], staff['absent']),
          ),
        ),
      )
          .toList(),
    );
  }

  // Student Attendance
  Widget _buildStudentAttendance() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Dropdown for Department
          DropdownButtonFormField<String>(
            value: selectedDept,
            items: const [
              DropdownMenuItem(value: 'CS', child: Text('Computer Science')),
              DropdownMenuItem(value: 'IT', child: Text('Information Technology')),
              DropdownMenuItem(value: 'ME', child: Text('Mechanical Engineering')),
            ],
            onChanged: (value) {
              setState(() {
                selectedDept = value!;
                selectedClass = value == 'CS' ? 'CS101' : 'IT201';
              });
            },
            decoration: const InputDecoration(labelText: 'Select Department'),
          ),
          const SizedBox(height: 12.0),

          // Dropdown for Class
          DropdownButtonFormField<String>(
            value: selectedClass,
            items: [
              DropdownMenuItem(value: 'CS101', child: Text('CS101')),
              DropdownMenuItem(value: 'IT201', child: Text('IT201')),
            ],
            onChanged: (value) {
              setState(() {
                selectedClass = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Select Class'),
          ),
          const SizedBox(height: 16.0),

          // Attendance List
          Expanded(
            child: ListView(
              children: studentAttendance
                  .where((student) =>
              student['dept'] == selectedDept &&
                  student['class'] == selectedClass)
                  .map(
                    (student) => Card(
                  child: ListTile(
                    title: Text(student['name']),
                    subtitle: Text('Class: ${student['class']}'),
                    trailing:
                    _buildAttendanceBar(student['present'], student['absent']),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Attendance Progress Bar
  Widget _buildAttendanceBar(int present, int absent) {
    double total = present + absent.toDouble();
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Expanded(
            flex: present,
            child: Container(
              height: 10.0,
              color: Colors.green,
            ),
          ),
          Expanded(
            flex: absent,
            child: Container(
              height: 10.0,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ClerkRequestPage extends StatefulWidget {
  const ClerkRequestPage({Key? key}) : super(key: key);

  @override
  _ClerkRequestPageState createState() => _ClerkRequestPageState();
}

class _ClerkRequestPageState extends State<ClerkRequestPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<String> passOptions = ["Bus Pass", "Bonafide", "Train Pass"];

  // Navigate to list of requests for a specific pass type
  void navigateToRequestList(String passType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestListPage(passType: passType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requests Overview")),
      body: ListView.builder(
        itemCount: passOptions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                passOptions[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => navigateToRequestList(passOptions[index]),
            ),
          );
        },
      ),
    );
  }
}

class RequestListPage extends StatefulWidget {
  final String passType;

  const RequestListPage({Key? key, required this.passType}) : super(key: key);

  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, Map<String, dynamic>> studentRequests = {};

  @override
  void initState() {
    super.initState();
    fetchStudentRequests();
  }

  // Fetch all student requests for the given pass type
  Future<void> fetchStudentRequests() async {
    DatabaseReference passRef = _database.child("Request").child(widget.passType);
    DataSnapshot snapshot = await passRef.get();
    if (snapshot.exists) {
      Map<String, Map<String, dynamic>> tempRequests = {};

      // Iterate over departments
      for (var department in snapshot.children) {
        String departmentKey = department.key ?? "UnknownDept";

        for (var semester in department.children) {
          String semesterKey = semester.key ?? "UnknownSem";

          for (var student in semester.children) {
            String studentId = student.key ?? "UnknownID";
            String requestDate = student.child("date").value?.toString() ?? "Unknown Date";
            bool isSolved = student.child("solve").value == true;

            tempRequests["$departmentKey/$semesterKey/$studentId"] = {
              "date": requestDate,
              "solved": isSolved,
            };
          }
        }
      }

      setState(() {
        studentRequests = tempRequests;
      });
    }
  }

  // Mark the request as solved
  Future<void> markRequestAsSolved(String path) async {
    await _database.child("Request").child(widget.passType).child(path).update({"solve": true});
    fetchStudentRequests();
    Navigator.pop(context);
  }

  // Show confirmation dialog
  void showConfirmationDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Request Completion"),
        content: const Text("Did the student request complete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => markRequestAsSolved(path),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.passType} Requests")),
      body: studentRequests.isEmpty
          ? const Center(child: Text("No requests found"))
          : ListView.builder(
        itemCount: studentRequests.length,
        itemBuilder: (context, index) {
          String path = studentRequests.keys.elementAt(index);
          String studentId = path.split('/').last;
          String requestDate = studentRequests[path]?["date"] ?? "Unknown Date";
          bool isSolved = studentRequests[path]?["solved"] ?? false;

          return Card(
            margin: const EdgeInsets.all(8),
            color: isSolved ? Colors.lightGreen[200] : Colors.white,
            child: ListTile(
              title: Text("Student ID: $studentId"),
              subtitle: Text("Requested on: $requestDate"),
              onTap: () => showConfirmationDialog(path),
            ),
          );
        },
      ),
    );
  }
}

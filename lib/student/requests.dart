import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class RequestPage extends StatefulWidget {
  final String department;
  final String semester;
  final String studentId;

  const RequestPage({Key? key, required this.department, required this.semester, required this.studentId}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<String> passOptions = ["Bus Pass", "Bonafide", "Train Pass"];
  Map<String, Map<String, dynamic>> requests = {};

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    for (String passType in passOptions) {
      DatabaseReference studentRef = _database
          .child("Request")
          .child(passType)
          .child(widget.department)
          .child(widget.semester)
          .child(widget.studentId);

      DataSnapshot snapshot = await studentRef.get();
      if (snapshot.exists) {
        String requestDate = snapshot.child("date").value.toString();
        bool isSolved = snapshot.child("solve").value == true;
        setState(() {
          requests[passType] = {"date": requestDate, "solved": isSolved};
        });
      }
    }
  }

  Future<void> requestPass(String passType) async {
    DatabaseReference studentRef = _database
        .child("Request")
        .child(passType)
        .child(widget.department)
        .child(widget.semester)
        .child(widget.studentId);

    DataSnapshot snapshot = await studentRef.get();
    if (snapshot.exists) {
      String lastRequestedDate = snapshot.child("date").value.toString();
      DateTime lastDate = DateFormat("yyyy-MM-dd").parse(lastRequestedDate);
      DateTime now = DateTime.now();
      if (now.difference(lastDate).inDays < 60) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You can request $passType only once in 2 months!"))
        );
        return;
      }
    }

    String currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    await studentRef.set({"request": passType, "date": currentDate, "solve": false});
    fetchRequests();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$passType requested successfully!"))
    );
    Navigator.pop(context);
  }

  Future<void> deleteRequest(String passType) async {
    DatabaseReference studentRef = _database
        .child("Request")
        .child(passType)
        .child(widget.department)
        .child(widget.semester)
        .child(widget.studentId);

    await studentRef.remove();
    setState(() {
      requests.remove(passType);
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$passType request deleted successfully!"))
    );
  }


  void showRequestDialog() {
    String? selectedPass;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Request a Pass"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: const Text("Select a pass"),
                    value: selectedPass,
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedPass = newValue;
                      });
                    },
                    items: passOptions.map((String pass) {
                      return DropdownMenuItem<String>(
                        value: pass,
                        child: Text(pass),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedPass != null) {
                      requestPass(selectedPass!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a pass type!"))
                      );
                    }
                  },
                  child: const Text("Request"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Requests")),
      body: requests.isEmpty
          ? const Center(child: Text("No requests found"))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          String passType = requests.keys.elementAt(index);
          String requestDate = requests[passType]!["date"];
          bool isSolved = requests[passType]!["solved"];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isSolved ? Colors.lightGreen : Colors.white,
            child: ListTile(
              title: Text(
                passType,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Requested on: $requestDate"),
              leading: const Icon(Icons.card_membership, color: Colors.blue),
              trailing: isSolved
                  ? null
                  : IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteRequest(passType),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showRequestDialog,
        child: const Icon(Icons.create),
        tooltip: "Request Pass",
      ),
    );
  }
}

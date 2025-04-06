import 'package:NCSC/Services/Send_Notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  bool is_loading=true;
  bool is_avil=true;

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
            var token=await FirebaseDatabase.instance.ref("Users/${studentId}")
                .child("token").get();
            var name=await FirebaseDatabase.instance.ref("Students/${studentId}/name").get();
            //print("Token:${token.value.toString()}");
            String requestDate = student.child("date").value?.toString() ?? "Unknown Date";
            bool isSolved = student.child("solve").value == true;

            tempRequests["$studentId"] = {
              "dept":departmentKey,
              "sem":semesterKey,
              "name":name.value.toString(),
              "token":token.value?.toString()??"No Token",
              "date": requestDate,
              "solved": isSolved,
            };
            print(studentRequests[studentId]?["token"]);
            print(tempRequests);
          }
        }
      }

      setState(() {
        studentRequests = tempRequests;
        is_loading=false;
        is_avil=true;
      });
    }
    else{
      setState(() {
        is_loading=false;
        is_avil=false;
      });
    }
  }

  // Mark the request as solved
  Future<void> markRequestAsSolved(String path) async {
    await _database.child("Request").child(widget.passType)
        .child(studentRequests[path]?["dept"])
        .child(studentRequests[path]?["sem"])
        .child(path)
        .update({"solve": true})
        .then((_)async{
          if (studentRequests[path]?["token"]!="No Token"){
            await SendNotification.sendNotificationbyAPI(
                token: studentRequests[path]?["token"],
                title: "NCSC",
                body: "Your Request for ${widget.passType} is accepted\n"
                    "Kindly Collect it from Admin Office in Working Hours"
            );
          }
          Fluttertoast.showToast(msg: "Notification Send to user");
          fetchStudentRequests();
          Navigator.pop(context);
        }).catchError((error){
          Fluttertoast.showToast(msg: "${error.toString()}");
        });
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
      body:Stack(
        children: [
          is_loading
              ?
          const Center(child: CircularProgressIndicator(),)
              :
          ListView.builder(
            itemCount: studentRequests.length,
            itemBuilder: (context, index) {
              String path = studentRequests.keys.elementAt(index);
              String requestDate = studentRequests[path]?["date"] ?? "Unknown Date";
              String name = studentRequests[path]?["name"] ?? "Unknown";
              bool isSolved = studentRequests[path]?["solved"] ?? false;
              String dept= studentRequests[path]?["dept"];
              String sem= studentRequests[path]?["sem"];

              return Card(
                margin: const EdgeInsets.all(8),
                color: isSolved ? Colors.lightGreen[200] : Colors.white,
                child: ListTile(
                  title: Text("$path\n$name"),
                  subtitle: Text("Requested on: $requestDate"),
                  trailing: Text("$dept\nSem:$sem"),
                  onTap: () {
                    if(isSolved==false)
                      showConfirmationDialog(path);
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${widget.passType} Request Solved"),
                            duration: Duration(seconds: 1),
                          )
                      );
                    }
                  },
                ),
              );
            },
          ),
          if(is_avil==false)
            Center(
              child: Text(
                "No Request Found",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
              ),
            ),
        ],
      )
    );
  }
}

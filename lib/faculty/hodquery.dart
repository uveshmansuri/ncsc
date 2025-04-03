import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HodDepartmentQuery extends StatefulWidget {
  final String dept;
  const HodDepartmentQuery({Key? key, required this.dept}) : super(key: key);

  @override
  _HodDepartmentQueryPageState createState() => _HodDepartmentQueryPageState();
}

class _HodDepartmentQueryPageState extends State<HodDepartmentQuery> {
  late DatabaseReference queryRef;
  List<Map<dynamic, dynamic>> queries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    queryRef = FirebaseDatabase.instance.ref().child('Query').child('departmentquery').child(widget.dept);
    _loadDepartmentQueries();
  }

  Future<void> _loadDepartmentQueries() async {
    final snapshot = await queryRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (var semester in data.keys) {
        var semesterData = data[semester];
        if (semesterData is Map) {
          for (var studId in semesterData.keys) {
            var queryList = semesterData[studId];
            if (queryList is Map) {
              // Fetch student name
              String studentName = await _getStudentName(studId);
              for (var key in queryList.keys) {
                var query = queryList[key];
                if (query is Map) {
                  queries.add({
                    ...query,
                    'key': key,
                    'studId': studId,
                    'semester': semester,
                    'studentName': studentName, // Store student name
                  });
                }
              }
            }
          }
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<String> _getStudentName(String studId) async {
    final studentSnapshot = await FirebaseDatabase.instance.ref().child('Students').child(studId).child('name').get();
    if (studentSnapshot.exists) {
      return studentSnapshot.value.toString();
    }
    return "Unknown Student";
  }


  void _markAsResolved(int index) async {
    final query = queries[index];
    String studId = query['studId'];
    String semester = query['semester'];
    String key = query['key'];

    await queryRef.child(semester).child(studId).child(key).update({'resolved': true});

    setState(() {
      queries[index]['resolved'] = true;
    });
  }

  void _confirmResolution(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark as Resolved'),
        content: Text('Are you sure this query is resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              _markAsResolved(index);
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Department Queries (${widget.dept})'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : queries.isEmpty
          ? const Center(
        child: Text(
          'No department queries found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: queries.length,
          itemBuilder: (context, index) {
            final query = queries[index];
            bool isResolved = query['resolved'] == true;
            return Card(
              color: isResolved ? Colors.grey[300] : Colors.white,
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: Text(
                  query['subject'] ?? 'No Subject',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isResolved ? Colors.grey[600] : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Student: ${query['studentName']}", // ✅ Show student name
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      query['description'] ?? 'No Description',
                      style: TextStyle(
                        fontSize: 16,
                        color: isResolved ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                  ],
                ),
                leading: Icon(
                  Icons.check_circle,
                  color: isResolved ? Colors.green : Colors.blueAccent,
                ),
                onTap: () => _confirmResolution(index),
              )

            );
          },
        ),
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FetchComputerLabQueries extends StatefulWidget {
  @override
  _FetchComputerLabQueriesState createState() => _FetchComputerLabQueriesState();
}

class _FetchComputerLabQueriesState extends State<FetchComputerLabQueries> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> computerLabQueries = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchAllQueries();
  }

  /// ✅ Fetch Queries (Handles Both List & Map Cases)
  void _fetchAllQueries() async {
    try {
      DatabaseEvent event = await _database.child('Query/computerlab').once();

      if (event.snapshot.exists) {
        var rawData = event.snapshot.value;
        List<Map<String, dynamic>> tempList = [];

        if (rawData is List<dynamic>) {
          // ✅ Case: `Query/computerlab` is a List with Maps inside
          for (var item in rawData) {
            if (item is Map<dynamic, dynamic>) {
              item.forEach((queryId, queryData) {
                if (queryData is Map<dynamic, dynamic>) {
                  tempList.add({
                    'queryId': queryId.toString(),
                    'pcnumber': queryData['pcnumber'] ?? 'Unknown PC',
                    'description': queryData['description'] ?? 'No description',
                    'image': queryData['image'] ?? 'https://via.placeholder.com/150',
                    'resolved': queryData['resolved'] ?? false,
                  });
                }
              });
            }
          }
        } else if (rawData is Map<dynamic, dynamic>) {
          // ✅ Case: `Query/computerlab/{stud_id}/{query_id}`
          rawData.forEach((studId, queries) {
            if (queries is Map<dynamic, dynamic>) {
              queries.forEach((queryId, queryData) {
                if (queryData is Map<dynamic, dynamic>) {
                  tempList.add({
                    'queryId': queryId.toString(),
                    'studId': studId?.toString() ?? 'Unknown',
                    'pcnumber': queryData['pcnumber'] ?? 'Unknown PC',
                    'description': queryData['description'] ?? 'No description',
                    'image': queryData['image'] ?? 'https://via.placeholder.com/150',
                    'resolved': queryData['resolved'] ?? false,
                  });
                }
              });
            }
          });
        } else {
          print("❌ Unexpected data format: $rawData");
        }

        setState(() {
          computerLabQueries = tempList;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void _resolveQuery(String? studId, String queryId, int index) async {
    try {
      // Show confirmation dialog before resolving
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Resolve Query"),
          content: Text("Are you sure you want to mark this query as resolved?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Resolve"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Construct the correct path using studId and queryId
        String path = studId != null && studId.isNotEmpty
            ? 'Query/computerlab/$studId/$queryId'
            : 'Query/computerlab/$queryId';

        // Update the existing query to add the 'resolved' field
        await _database.child(path).update({'resolved': true});
        setState(() {
          computerLabQueries[index]['resolved'] = true;
        });
      }
    } catch (e) {
      print("❌ Error resolving query: $e");
    }
  }





  /// ✅ Show Image Dialog (Full-Screen)
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(imageUrl, fit: BoxFit.cover),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Computer Lab Queries")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : computerLabQueries.isEmpty
          ? Center(child: Text("No queries available"))
          : ListView.builder(
        itemCount: computerLabQueries.length,
        itemBuilder: (context, index) {
          final query = computerLabQueries[index];
          return Card(
            margin: EdgeInsets.all(8),
            color: query['resolved'] ? Colors.grey[300] : Colors.white,
            child: ListTile(
              leading: query['image'] != null && query['image'] != 'https://via.placeholder.com/150'
                  ? GestureDetector(
                onTap: () => _showImageDialog(query['image']),
                child: Image.network(
                  query['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : null,
              title: Text(
                query['pcnumber'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(query['description']),
              trailing: IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: query['resolved'] ? Colors.grey : Colors.green,
                ),
                onPressed: query['resolved'] ? null : () => _resolveQuery(query['studId'], query['queryId'], index),
              ),
            )
          );
        },
      ),
    );
  }
}

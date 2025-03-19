import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FetchScienceLabQueries extends StatefulWidget {
  @override
  _FetchScienceLabQueriesState createState() => _FetchScienceLabQueriesState();
}

class _FetchScienceLabQueriesState extends State<FetchScienceLabQueries> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> scienceLabQueries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllQueries();
  }

  void _fetchAllQueries() async {
    try {
      DatabaseEvent event = await _database.child('Query/sciencelab').once();

      if (event.snapshot.exists) {
        var rawData = event.snapshot.value;
        List<Map<String, dynamic>> tempList = [];

        if (rawData is Map<dynamic, dynamic>) {
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
        }

        setState(() {
          scienceLabQueries = tempList;
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
        String path = studId != null && studId.isNotEmpty
            ? 'Query/sciencelab/$studId/$queryId'
            : 'Query/sciencelab/$queryId';
        await _database.child(path).update({'resolved': true});
        setState(() {
          scienceLabQueries[index]['resolved'] = true;
        });
      }
    } catch (e) {
      print("❌ Error resolving query: $e");
    }
  }

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
      appBar: AppBar(title: Text("Science Lab Queries")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : scienceLabQueries.isEmpty
          ? Center(child: Text("No queries available"))
          : ListView.builder(
        itemCount: scienceLabQueries.length,
        itemBuilder: (context, index) {
          final query = scienceLabQueries[index];
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
            ),
          );
        },
      ),
    );
  }
}

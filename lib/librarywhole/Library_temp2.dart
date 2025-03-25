import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LibraryDashboard extends StatefulWidget {
  @override
  _LibraryDashboardState createState() => _LibraryDashboardState();
}

class _LibraryDashboardState extends State<LibraryDashboard> {
  final List<Map<String, dynamic>> books = [
    {"id": "B001", "title": "Data Structures", "status": "Available", "dueDate": null},
    {"id": "B002", "title": "Flutter for Beginners", "status": "Issued", "dueDate": DateTime.now().add(Duration(days: 1))}, // 1 day left
    {"id": "B003", "title": "Database Systems", "status": "Issued", "dueDate": DateTime.now().subtract(Duration(days: 3))}, // Overdue
    {"id": "B004", "title": "Operating Systems", "status": "Lost", "dueDate": null},
  ];

  final List<Map<String, dynamic>> members = [
    {"id": "S001", "name": "John Doe", "booksIssued": 2, "fine": 50},
    {"id": "S002", "name": "Jane Smith", "booksIssued": 1, "fine": 0},
  ];

  String searchQuery = "";
  String selectedStatus = "All";

  List<Map<String, dynamic>> get filteredBooks {
    return books.where((book) {
      final matchesSearch = book["title"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          book["id"].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatus == "All" || book["status"] == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<Map<String, dynamic>> get overdueBooks {
    return books.where((book) {
      if (book["status"] == "Issued" && book["dueDate"] != null) {
        final daysLeft = book["dueDate"].difference(DateTime.now()).inDays;
        return daysLeft < 0; // Overdue books
      }
      return false;
    }).toList();
  }

  List<Map<String, dynamic>> get nearDueBooks {
    return books.where((book) {
      if (book["status"] == "Issued" && book["dueDate"] != null) {
        final daysLeft = book["dueDate"].difference(DateTime.now()).inDays;
        return daysLeft <= 2 && daysLeft >= 0; // Near overdue books
      }
      return false;
    }).toList();
  }

  void _showNotifications() {
    if (overdueBooks.isNotEmpty || nearDueBooks.isNotEmpty) {
      String message = "";
      if (nearDueBooks.isNotEmpty) {
        message += "📢 Books near overdue:\n";
        nearDueBooks.forEach((book) {
          message += "🔹 ${book["title"]} (Due: ${DateFormat('dd MMM').format(book["dueDate"])})\n";
        });
      }
      if (overdueBooks.isNotEmpty) {
        message += "\n❗ Overdue Books:\n";
        overdueBooks.forEach((book) {
          message += "❌ ${book["title"]} (Due: ${DateFormat('dd MMM').format(book["dueDate"])})\n";
        });
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Library Notifications"),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _showNotifications); // Show notifications on load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: "Search Books",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            SizedBox(height: 10),

            // Status Filter
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: ["All", "Available", "Issued", "Lost"].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (newStatus) {
                setState(() {
                  selectedStatus = newStatus!;
                });
              },
              decoration: InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // Book List with Notifications
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final isOverdue = book["status"] == "Issued" && book["dueDate"] != null && book["dueDate"].isBefore(DateTime.now());
                  final isNearDue = book["status"] == "Issued" && book["dueDate"] != null && book["dueDate"].difference(DateTime.now()).inDays <= 2;

                  return Card(
                    color: isOverdue ? Colors.red[100] : (isNearDue ? Colors.orange[100] : null),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(book['title']),
                      subtitle: Text(
                          'Status: ${book['status']} ${book["dueDate"] != null ? "\nDue: ${DateFormat('dd MMM').format(book["dueDate"])}" : ""}'),
                      trailing: isOverdue
                          ? Icon(Icons.error, color: Colors.red)
                          : (isNearDue ? Icon(Icons.warning, color: Colors.orange) : Icon(Icons.check_circle, color: Colors.green)),
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
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DepartmentQuery extends StatefulWidget {
  final String stud_id;
  const DepartmentQuery({Key? key, required this.stud_id}) : super(key: key);

  @override
  _StudentQueryPageState createState() => _StudentQueryPageState();
}

class _StudentQueryPageState extends State<DepartmentQuery> {
  late DatabaseReference queryRef;
  List<Map<dynamic, dynamic>> queries = [];
  List<String> queryKeys = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    queryRef = FirebaseDatabase.instance.ref().child('Students').child(widget.stud_id);
    _loadQueries();
  }

  Future<void> _loadQueries() async {
    final snapshot = await queryRef.get();
    if (snapshot.exists) {
      final studentData = snapshot.value as Map<dynamic, dynamic>;
      String department = studentData['dept'];
      String semester = studentData['sem'];

      final querySnapshot = await FirebaseDatabase.instance
          .ref()
          .child('Query')
          .child('departmentquery')
          .child(department)
          .child(semester)
          .child(widget.stud_id)
          .get();

      if (querySnapshot.exists) {
        final data = querySnapshot.value as Map<dynamic, dynamic>;
        queryKeys = data.keys.map((key) => key.toString()).toList();
        queries = data.values.map((e) => e as Map<dynamic, dynamic>).toList();
      }
    }
    setState(() {
      isLoading = false;
    });
  }
  void _deleteQuery(int index) async {
    try {
      String key = queryKeys[index];
      final snapshot = await queryRef.get();
      if (snapshot.exists) {
        final studentData = snapshot.value as Map<dynamic, dynamic>;
        String department = studentData['dept'];
        String semester = studentData['sem'];

        await FirebaseDatabase.instance
            .ref()
            .child('Query')
            .child('departmentquery')
            .child(department)
            .child(semester)
            .child(widget.stud_id)
            .child(key)
            .remove();

        setState(() {
          queries.removeAt(index);
          queryKeys.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Query deleted successfully!')),
        );
      }
    } catch (e) {
      print('Error deleting query: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete query.')),
      );
    }
  }


  void _editQuery(int index) {
    TextEditingController subjectController = TextEditingController(text: queries[index]['subject']);
    TextEditingController descriptionController = TextEditingController(text: queries[index]['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Query"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String key = queryKeys[index];
              try {
                final snapshot = await queryRef.get();
                if (snapshot.exists) {
                  final studentData = snapshot.value as Map<dynamic, dynamic>;
                  String department = studentData['dept'];
                  String semester = studentData['sem'];

                  await FirebaseDatabase.instance
                      .ref()
                      .child('Query')
                      .child('departmentquery')
                      .child(department)
                      .child(semester)
                      .child(widget.stud_id)
                      .child(key)
                      .update({
                    'subject': subjectController.text,
                    'description': descriptionController.text,
                  });

                  setState(() {
                    queries[index]['subject'] = subjectController.text;
                    queries[index]['description'] = descriptionController.text;
                  });

                  Navigator.pop(context); // Close the dialog after saving
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Query updated successfully!')),
                  );
                }
              } catch (e) {
                print('Error updating query: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update query.')),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Queries'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : queries.isEmpty
          ? const Center(
        child: Text(
          'No queries sent yet.',
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
            return GestureDetector(
              onLongPress: isResolved ? null : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Query"),
                    content: const Text("Are you sure you want to delete this query?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteQuery(index);
                          Navigator.pop(context);
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child:Dismissible(
                key: Key(queryKeys[index]),
                direction: isResolved ? DismissDirection.none : DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    _editQuery(index);
                    return false;
                  }
                  return false;
                },
                background: Container(
                  color: Colors.orange,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                child: Card(
                  elevation: 5,
                  color: isResolved ? Colors.grey[300] : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(query['subject'] ?? 'No Subject',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isResolved ? Colors.grey : Colors.black)),
                    subtitle: Text(query['description'] ?? 'No Description',
                        style: TextStyle(
                            fontSize: 16,
                            color: isResolved ? Colors.grey[700] : Colors.black)),
                    leading: const Icon(Icons.question_answer, color: Colors.blueAccent),
                  ),
                ),
              ),

            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateQueryPage(studId: widget.stud_id),
            ),
          ).then((_) => _loadQueries());
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class CreateQueryPage extends StatelessWidget {
  final String studId;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  CreateQueryPage({Key? key, required this.studId}) : super(key: key);

  void _submitQuery(BuildContext context) async {
    String subject = subjectController.text;
    String description = descriptionController.text;

    if (subject.isEmpty || description.isEmpty) return;

    final studentSnapshot = await FirebaseDatabase.instance.ref().child('Students').child(studId).get();
    if (studentSnapshot.exists) {
      final studentData = studentSnapshot.value as Map<dynamic, dynamic>;
      String department = studentData['dept'];
      String semester = studentData['sem'];

      final queryRef = FirebaseDatabase.instance
          .ref()
          .child('Query')
          .child('departmentquery')
          .child(department)
          .child(semester)
          .child(studId)
          .push();

      await queryRef.set({
        'subject': subject,
        'description': description,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Query'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitQuery(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

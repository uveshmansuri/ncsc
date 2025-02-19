import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CircularPage extends StatefulWidget {
  const CircularPage({Key? key}) : super(key: key);

  @override
  State<CircularPage> createState() => _CircularPageState();
}

class _CircularPageState extends State<CircularPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedSubject;
  String? selectedSemester;
  List<Map<String, String>> subjectsList = [];

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("facultycircular");

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }
  Future<void> fetchSubjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Subjects");
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      List<Map<String, String>> tempList = [];
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        tempList.add({
          "name": value["name"], // Subject name
          "sem": value["sem"],   // Semester
        });
      });

      setState(() {
        subjectsList = tempList;
      });
    }
  }

  void _addCircular() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty && selectedSubject != null && selectedSemester != null) {
      databaseRef.push().set({
        'title': title,
        'description': description,
        'subject': selectedSubject!,
        'semester': selectedSemester!,
        'date': DateTime.now().toString().substring(0, 10), // Current date
      }).then((_) {
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          selectedSubject = null;
          selectedSemester = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Circular created successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Faculty Circular'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Circular Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Circular Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),

            // Circular Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Circular Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12.0),

            // Subject Dropdown
            DropdownButtonFormField<String>(
              value: selectedSubject,
              hint: const Text("Select Subject"),
              items: subjectsList.map((subject) {
                return DropdownMenuItem(
                  value: subject["name"],
                  child: Text(subject["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                  selectedSemester = subjectsList.firstWhere((element) => element["name"] == value)?["sem"];
                });
              },
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            Text("Semester", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              selectedSemester ?? "Select a subject first",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _addCircular,
              icon: const Icon(Icons.add),
              label: const Text('Create Circular'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder(
                stream: databaseRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                    Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Map<String, String>> circulars = [];

                    data.forEach((key, value) {
                      circulars.add({
                        "title": value["title"],
                        "description": value["description"],
                        "subject": value["subject"],
                        "semester": value["semester"],
                        "date": value["date"],
                      });
                    });
                    return ListView.builder(
                      itemCount: circulars.length,
                      itemBuilder: (context, index) {
                        final circular = circulars[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.notifications,
                              color: Colors.blue,
                            ),
                            title: Text(circular['title']!),
                            subtitle: Text(
                              'Subject: ${circular['subject']}\nSemester: ${circular['semester']}\nDate: ${circular['date']}\n\n${circular['description']}',
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No circulars available."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

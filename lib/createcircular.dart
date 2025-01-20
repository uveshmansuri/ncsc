import 'package:flutter/material.dart';

class CreateCircularScreen extends StatefulWidget {
  const CreateCircularScreen({Key? key}) : super(key: key);

  @override
  State<CreateCircularScreen> createState() => _CreateCircularScreenState();
}

class _CreateCircularScreenState extends State<CreateCircularScreen> {

  final List<Map<String, String>> circularList = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedAudience = 'All'; // Default audience group

  void _addCircular() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty) {
      setState(() {
        circularList.add({
          'title': title,
          'description': description,
          'audience': selectedAudience,
          'date': DateTime.now().toString().substring(0, 10), // Current date
        });
      });

      // Clear input fields
      _titleController.clear();
      _descriptionController.clear();
      selectedAudience = 'All';

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Circular created successfully!')),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Circular'),
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

            // Audience Dropdown
            DropdownButtonFormField<String>(
              value: selectedAudience,
              items: const [
                DropdownMenuItem(value: 'Faculty', child: Text('Faculty')),
                DropdownMenuItem(value: 'Students', child: Text('Students')),
                DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                DropdownMenuItem(value: 'All', child: Text('All')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedAudience = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Audience',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Add Circular Button
            ElevatedButton.icon(
              onPressed: _addCircular,
              icon: const Icon(Icons.add),
              label: const Text('Create Circular'),
            ),
            const SizedBox(height: 16.0),

            // Display Circular List
            Expanded(
              child: ListView.builder(
                itemCount: circularList.length,
                itemBuilder: (context, index) {
                  final circular = circularList[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Colors.blue,
                      ),
                      title: Text(circular['title']!),
                      subtitle: Text(
                        'Audience: ${circular['audience']}\nDate: ${circular['date']}\n\n${circular['description']}',
                      ),
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


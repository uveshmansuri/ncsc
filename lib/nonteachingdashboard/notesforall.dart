import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final String username;
  const CalendarScreen({required this.username, Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DatabaseReference _dbRef;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, Map<String, String>> _events = {};
  Set<DateTime> _eventDays = {};

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref().child("Users").child(widget.username).child("notes");
    _fetchEvents();
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Fetch events from Firebase and update the UI
  void _fetchEvents() {
    _dbRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<DateTime, Map<String, String>> fetchedEvents = {};
        Set<DateTime> highlightedDates = {};

        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((dateKey, eventData) {
          try {
            DateTime eventDate = DateTime.parse(dateKey);
            fetchedEvents[eventDate] = {
              "title": eventData["title"] ?? "No Title",
              "description": eventData["description"] ?? "No Description"
            };
            highlightedDates.add(eventDate);
          } catch (e) {
            print("Error parsing date: $dateKey - $e");
          }
        });

        setState(() {
          _events = fetchedEvents;
          _eventDays = highlightedDates;
        });
      }
    }).catchError((error) {
      print("Error fetching events: $error");
    });
  }

  void _showAddEventDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures proper keyboard behavior
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevents unnecessary height expansion
              children: [
                Text(
                  "Create Event - ${_formatDate(_selectedDay)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descController,
                  maxLines: 3, // Restricts height growth
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveEvent(titleController.text, descController.text);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Save"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveEvent(String title, String description) {
    String formattedDate = _formatDate(_selectedDay);
    _dbRef.child(formattedDate).set({
      "title": title,
      "description": description,
    }).then((_) {
      _fetchEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event added successfully!")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Calendar",
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor:Colors.teal,
      ),

      body: Column(
        children: [
          /// 📆 Table Calendar UI
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)],
              borderRadius: BorderRadius.circular(15),
            ),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) => _eventDays.contains(day) ? [1] : [],
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          /// 🎯 Create Event Button
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _showAddEventDialog,
            icon: Icon(Icons.add, size: 20),
            label: Text("Create Event"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),

          /// 📌 Event Display Area
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Builder(
                builder: (context) {
                  DateTime normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                  if (_events.containsKey(normalizedDay)) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📅 Event on ${_formatDate(normalizedDay)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Divider(),
                        Text("📝 Title: ${_events[normalizedDay]?['title']}", style: TextStyle(fontSize: 16)),
                        Text("📖 Description: ${_events[normalizedDay]?['description']}", style: TextStyle(fontSize: 16)),
                      ],
                    );
                  }
                  return Center(child: Text("No Event", style: TextStyle(fontSize: 16, color: Colors.grey)));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

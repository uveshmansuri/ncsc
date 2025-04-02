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
  late DatabaseReference _userRef;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Map<String, String>>> _events = {};
  Set<DateTime> _eventDays = {};
  bool _isFaculty = false;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref().child("Users")
        .child(widget.username)
        .child("notes");
    _userRef = FirebaseDatabase.instance.ref().child("Users").child(widget.username);
    _fetchUserRole();
    _fetchEvents();
  }
  void _fetchUserRole() {
    _userRef.child("role").once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        setState(() {
          userRole = event.snapshot.value.toString();
          _isFaculty = userRole == "faculty";
        });
      }
    }).catchError((error) {
      print("Error fetching user role: $error");
    });
  }

  void _fetchEvents() {
    Map<DateTime, List<Map<String, String>>> fetchedEvents = {};
    Set<DateTime> highlightedDates = {};

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");

    usersRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> usersData = event.snapshot.value as Map<dynamic, dynamic>;

        usersData.forEach((userId, userData) {
          if (userData is Map && userData.containsKey("notes")) {
            Map<dynamic, dynamic> notesData = userData["notes"];
            notesData.forEach((dateKey, noteDetails) {
              try {
                DateTime eventDate = DateTime.parse(dateKey);
                List<Map<String, String>> eventList = fetchedEvents[eventDate] ?? [];
                bool facNote = noteDetails["fac_note"] ?? false;
                bool stuNote = noteDetails["stu_note"] ?? false;
                String facultyName = noteDetails["faculty"] ?? "Unknown";
                if ((userRole == "student" && stuNote) || userRole == "faculty") {
                  eventList.add({
                    "title": noteDetails["title"] ?? "No Title",
                    "description": noteDetails["description"] ?? "No Description",
                    "faculty": facultyName,
                    "fac_note": facNote.toString(),
                    "stu_note": stuNote.toString(),
                  });
                }

                fetchedEvents[eventDate] = eventList;
                highlightedDates.add(eventDate);
              } catch (e) {
                print("Error parsing date: $dateKey - $e");
              }
            });
          }
        });

        setState(() {
          _events = fetchedEvents;
          _eventDays = highlightedDates;
        });
      }
    });
  }


  void _showAddEventDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    bool sendToStudents = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_isFaculty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Send to:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              Radio(
                                value: false,
                                groupValue: sendToStudents,
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    sendToStudents = value!;
                                  });
                                },
                              ),
                              Text("Faculty Only"),
                              Radio(
                                value: true,
                                groupValue: sendToStudents,
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    sendToStudents = value!;
                                  });
                                },
                              ),
                              Text("Faculty & Students"),
                            ],
                          ),
                        ],
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
                            _saveEvent(titleController.text, descController.text, sendToStudents);
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
      },
    );
  }
  void _saveEvent(String title, String description, bool sendToStudents) {
    String formattedDate = _formatDate(_selectedDay);

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(widget.username);
    userRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        String role = userData["role"] ?? "";

        if (role == "faculty") {
          DatabaseReference facultyNoteRef = FirebaseDatabase.instance.ref()
              .child("Users/${widget.username}/notes/$formattedDate");

          facultyNoteRef.set({
            "title": title,
            "description": description,
            "faculty": widget.username,
            "fac_note": true,
            "stu_note": false,
          });

          if (sendToStudents) {
            DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("Users");
            usersRef.once().then((DatabaseEvent event) {
              if (event.snapshot.exists) {
                Map<dynamic, dynamic> usersData = event.snapshot.value as Map<dynamic, dynamic>;
                usersData.forEach((userId, userData) {
                  if (userData is Map && userData["role"] == "student") {
                    DatabaseReference studentNoteRef = FirebaseDatabase.instance.ref()
                        .child("Users/$userId/notes/$formattedDate");
                    studentNoteRef.set({
                      "title": title,
                      "description": description,
                      "faculty": widget.username,
                      "fac_note": true,
                      "stu_note": true,
                    });
                  }
                });
              }
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Event added successfully!")),
          );
        } else if (role == "student") {
          FirebaseDatabase.instance.ref()
              .child("Users/${widget.username}/notes/$formattedDate")
              .set({
            "title": title,
            "description": description,
            "fac_note": false,
            "stu_note": true,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Personal note added successfully!")),
          );
        }
      }
    });
  }
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Calendar"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
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
                markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ),
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
                        Text("📅 Events on ${_formatDate(normalizedDay)}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Divider(),
                        Flexible(
                          child: ListView.separated(
                            itemCount: _events[normalizedDay]!
                                .where((event) => event['stu_note'] == true) // Ensure it's checking boolean `true`
                                .length,
                            separatorBuilder: (context, index) => SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              var filteredEvents = _events[normalizedDay]!
                                  .where((event) => event['stu_note'] == true) // Ensure filtering correctly
                                  .toList();

                              var event = filteredEvents[index];

                              return Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.teal),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("📝 Title: ${event['title']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text("📖 Description: ${event['description']}", style: TextStyle(fontSize: 15)),
                                    SizedBox(height: 4),
                                    if (event['fac_note'] == true) ...[
                                      Text("👩‍🏫 Faculty Name: ${event['faculty']}", style: TextStyle(fontSize: 15)),
                                      Text("📌 Note for Faculty", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                                    ],
                                    if (event['stu_note'] == true) ...[
                                      Text("👨‍🎓 Shared with Students", style: TextStyle(fontSize: 14, color: Colors.green)),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
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

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
  Map<DateTime, Map<String, dynamic>> _events = {};
  Set<DateTime> _eventDays = {};
  bool isFaculty = false;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instance.ref().child("Users").child(widget.username).child("notes");
    _fetchUserRole();
    _fetchEvents();
  }
  void _fetchUserRole() async {
    DatabaseReference roleRef = FirebaseDatabase.instance.ref().child("Users").child(widget.username).child("role");

    try {
      DatabaseEvent event = await roleRef.once();
      if (event.snapshot.exists) {
        String role = event.snapshot.value.toString().toLowerCase();
        setState(() {
          isFaculty = (role == "faculty");
        });
      }
    } catch (error) {
      print("Error fetching role: $error");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _fetchEvents() {
    _events.clear();
    _eventDays.clear();

    _dbRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((dateKey, eventData) {
          try {
            DateTime eventDate = DateTime.parse(dateKey);
            _events[eventDate] = {}; // Initialize as empty map

            (eventData as Map<dynamic, dynamic>).forEach((noteKey, noteDetails) {
              _events[eventDate]![noteKey] = {
                "title": noteDetails["title"] ?? "No Title",
                "description": noteDetails["description"] ?? "No Description",};
            });

            _eventDays.add(eventDate);
          } catch (e) {
            print("Error parsing personal notes date: $dateKey - $e");
          }
        });
      }
    }).catchError((error) {
      print("Error fetching personal notes: $error");
    });
    DatabaseReference facultyEventRef = FirebaseDatabase.instance.ref().child("event");
    facultyEventRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> facultyData = event.snapshot.value as Map<dynamic, dynamic>;

        facultyData.forEach((facultyID, notesData) {
          if (notesData["notes"] != null) {
            DatabaseReference facultyNameRef = FirebaseDatabase.instance.ref().child("Staff").child("faculty").child(facultyID).child("name");

            facultyNameRef.once().then((DatabaseEvent nameEvent) {
              String facultyName = nameEvent.snapshot.exists ? nameEvent.snapshot.value.toString() : facultyID;

              Map<dynamic, dynamic> notes = notesData["notes"];
              notes.forEach((dateKey, eventData) {
                try {
                  DateTime eventDate = DateTime.parse(dateKey);
                  _events.putIfAbsent(eventDate, () => {});

                  (eventData as Map<dynamic, dynamic>).forEach((noteKey, noteDetails) {
                    _events[eventDate]![noteKey] = {
                      "title": noteDetails["title"] ?? "No Title",
                      "description": noteDetails["description"] ?? "No Description",
                      "faculty": facultyName,
                    };
                  });

                  _eventDays.add(eventDate);
                } catch (e) {
                  print("Error parsing faculty notes date: $dateKey - $e");
                }
              });

              setState(() {});
            }).catchError((error) {
              print("Error fetching faculty name for $facultyID: $error");
            });
          }
        });
      }
    }).catchError((error) {
      print("Error fetching faculty notes: $error");
    });

    setState(() {});
  }




  void _showAddEventDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    String selectedAudience = "Faculty";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
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
                    Text("Create Event - ${_formatDate(_selectedDay)}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                    if (isFaculty)
                      DropdownButtonFormField<String>(
                        value: selectedAudience,
                        items: ["Faculty", "Student and Faculty"].map((audience) {
                          return DropdownMenuItem(
                            value: audience,
                            child: Text(audience),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedAudience = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Audience",
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
                            _saveEvent(titleController.text, descController.text, selectedAudience);
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



  void _saveEvent(String title, String description, String audience) {
    String formattedDate = _formatDate(_selectedDay);
    String noteKey = _dbRef.child(formattedDate).push().key!;

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("Users").child(widget.username).child("name");

    userRef.once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        String facultyName = event.snapshot.value.toString();

        Map<String, dynamic> newEvent = {
          "title": title,
          "description": description,
          "faculty": facultyName,
        };

        _dbRef.child(formattedDate).child(noteKey).set(newEvent).then((_) {
          if (audience == "Student and Faculty") {
            DatabaseReference eventRef = FirebaseDatabase.instance.ref()
                .child("event")
                .child(widget.username)
                .child("notes")
                .child(formattedDate)
                .child(noteKey);

            eventRef.set(newEvent);
          }

          _fetchEvents();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Event added successfully!")),
          );
        });
      }
    }).catchError((error) {
      print("Error fetching faculty name: $error");
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Calendar",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:Colors.teal,
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
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
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
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Builder(
                    builder: (context) {
                      DateTime normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                      if (_events.containsKey(normalizedDay)) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📅 Events on ${_formatDate(normalizedDay)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Divider(),
                            ..._events[normalizedDay]!.values.map((event) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("📝 Title: ${event['title']}", style: TextStyle(fontSize: 16)),
                                    Text("📖 Description: ${event['description']}", style: TextStyle(fontSize: 16)),
                                    Text(
                                      event['faculty'] != null
                                          ? "👨‍🏫 From ${event['faculty']} to student"
                                          : (isFaculty ? "📝 You created this for yourself" : ""),
                                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                                    ),

                                    Divider(),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }
                      return Center(child: Text("No Event", style: TextStyle(fontSize: 16, color: Colors.grey)));
                    },
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
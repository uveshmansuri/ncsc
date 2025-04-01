import 'package:NCSC/Services/Send_Notification.dart';
import 'package:NCSC/librarywhole/Library_DashBoard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AssingBook extends StatefulWidget {
  books_model book_data;
  AssingBook(this.book_data);

  @override
  State<AssingBook> createState() => _AssingBookState();
}

class _AssingBookState extends State<AssingBook> {
  List<BookAssing_model> assing_book_list=[];

  @override
  void initState() {
    fetch_assing_students();
    super.initState();
  }

  void fetch_assing_students() async{
    assing_book_list.clear();
    var db=await FirebaseDatabase.instance.ref("Books/${widget.book_data.book_id}/Assing").get();
    if(db.exists){
      for(DataSnapshot sp in db.children){
        var stud_id=sp.key;
        BookAssing_model obj=BookAssing_model(
            stud_id: stud_id,
            sname: sp.child("sname").value.toString(),
            due_date: sp.child("due_date").value.toString()
        );
        assing_book_list.add(obj);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Details"),
        actions: [
          // Icon for updating book details.
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "Update Book Details",
            onPressed: () {
              showUpdateBookDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Book details card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  widget.book_data.name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "${widget.book_data.author}\nDepartment: ${widget.book_data.dept}",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    showAssignBookDialog(context);
                  },
                  icon: Icon(Icons.assignment_turned_in_outlined),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Assignment list header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                assing_book_list.isNotEmpty
                    ? "List of Book Assigned Students"
                    : "0 Copies Assigned of this Book Currently",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 10),
            // Assignment list
            Expanded(
              child: assing_book_list.isEmpty
                  ? SizedBox()
                  : ListView.separated(
                separatorBuilder: (context, index) =>
                    SizedBox(height: 8),
                itemCount: assing_book_list.length,
                itemBuilder: (context, i) {
                  int daysLate = 0;
                  Color? cardColor;
                  bool notify = false;
                  DateTime currentDate = DateTime.now();
                  DateTime dueDate = DateFormat("yyyy-MM-dd")
                      .parse(assing_book_list[i].due_date);
                  if (currentDate.isAfter(dueDate)) {
                    daysLate = currentDate.difference(dueDate).inDays;
                    notify = true;
                    cardColor = daysLate == 0
                        ? Colors.blueAccent
                        : Colors.redAccent;
                  }
                  var assignment = assing_book_list[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: cardColor ?? Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Text(
                          assignment.stud_id.substring(0, 1).toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(assignment.sname),
                      subtitle: Text("Due: ${assignment.due_date}"),
                      trailing: notify
                          ? IconButton(
                        icon: Icon(Icons.notifications_active,
                            color: Colors.white),
                        onPressed: () {
                          Remainder_Student(assignment.stud_id, i);
                        },
                      )
                          : null,
                      onTap: () {
                        book_return(i);
                      },
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

  void showAssignBookDialog(BuildContext context) {
    if(widget.book_data.total_copies==0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book's Copies Not Available")));
      return;
    }
    DateTime dueDate = DateTime.now().add(Duration(days: 15));
    String formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
    TextEditingController studentIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                decoration: InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text("Due Date:$formattedDate"),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if(studentIdController.text.isNotEmpty){
                        assing_toStudent(studentIdController.text,formattedDate);
                        Navigator.pop(context); // Close the dialog
                      }else{
                        Fluttertoast.showToast(msg: "Enter Student ID");
                      }
                    },
                    child: Text('Assign'),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void assing_toStudent(var stud_id,var due_date) async{
    var db=await FirebaseDatabase.instance.ref("Students/$stud_id").get();
    if(db.exists){
      int remaining=widget.book_data.total_copies-1;
      await FirebaseDatabase.instance
          .ref("Books/${widget.book_data.book_id}/Assing/$stud_id")
          .set({
        "sname": db.child("name").value.toString(),
        "due_date": due_date
      }).then((_) async{
        await FirebaseDatabase.instance
            .ref("Books/${widget.book_data.book_id}/copies")
            .set(remaining)
            .then((_){
          widget.book_data.total_copies=remaining;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book Assingend to Student")));
          fetch_assing_students();
        });
      });
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Student Id")));
    }
  }

  void book_return(int index){
    int fineAmount=0;
    DateTime currentDate = DateTime.now();
    DateTime dueDate = DateFormat("yyyy-MM-dd").parse(assing_book_list[index].due_date);

    if (currentDate.isAfter(dueDate)) {
      int daysLate = currentDate.difference(dueDate).inDays;
      fineAmount = daysLate * 5;
    } else {
      fineAmount = 0;
    }

   showDialog(context: context, builder: (context){
     return AlertDialog(
       title: Text("Return Book - ${widget.book_data.name}"),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Text("Student Name:${assing_book_list[index].sname}"),
           Text("Due Date: ${assing_book_list[index].due_date}"),
           Text("Current Date: ${DateFormat("yyyy-MM-dd").format(DateTime.now())}"),
           SizedBox(height: 10),
           fineAmount > 0
               ? Text("Late Fee: ₹$fineAmount", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
               : Text("No Fine", style: TextStyle(color: Colors.green)),
         ],
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context),
           child: Text("Cancel"),
         ),
         TextButton(
           onPressed: (){
             Navigator.pop(context);
             collect_book(assing_book_list[index].stud_id,index);
           },
           child: Text("Collect"),
         ),
       ],
     );
   });
  }

  void collect_book(var stud_id,int i) async{
    var sp=await FirebaseDatabase.instance.ref("Books/${widget.book_data.book_id}/copies").get();
    int remaining=int.parse(sp.value.toString())+1;
    await FirebaseDatabase.instance
        .ref("Books/${widget.book_data.book_id}/Assing/$stud_id")
        .remove()
        .then((_) async{
      widget.book_data.total_copies=remaining;
          await FirebaseDatabase.instance
              .ref("Books/${widget.book_data.book_id}/copies")
              .set(remaining)
              .then((_){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book Collected")));
            setState(() {
              assing_book_list.removeAt(i);
            });
          });
        });
  }

  void Remainder_Student(String stud_id,i) async{
    var db=await FirebaseDatabase.instance.ref("Users/$stud_id/token").get();
    String token=db.value.toString();

    String msg;
    int fineAmount=0;
    int daysLate=0;
    DateTime currentDate = DateTime.now();
    DateTime dueDate = DateFormat("yyyy-MM-dd").parse(assing_book_list[i].due_date);

    if (currentDate.isAfter(dueDate)) {
      daysLate = currentDate.difference(dueDate).inDays;
      fineAmount = daysLate * 5;
    } else {
      fineAmount = 0;
    }

    if(fineAmount==0){
      msg="Reminder: Kindly return ${widget.book_data.name} to the library today between 11:00 AM and 4:30 PM to avoid a fine of ₹5 per day. Thank you!";
    }else{
      msg="Reminder: Your book ${widget.book_data.name} is $daysLate days overdue. "
          "A fine of ₹$fineAmount has been applied. Please return it as soon as possible to avoid further charges!";
    }

    int res=await SendNotification.sendNotificationbyAPI(token: token, title: "Book Return Alert", body: msg);

    if(res==0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student have not logged in into app")));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification Sent to the Student")));
    }
  }

  void showUpdateBookDialog(BuildContext context) {
    TextEditingController nameController =
    TextEditingController(text: widget.book_data.name);
    TextEditingController authorController =
    TextEditingController(text: widget.book_data.author);
    TextEditingController totalCopiesController = TextEditingController(
        text: widget.book_data.total_copies.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Book Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Book Name"),
                ),
                TextField(
                  controller: authorController,
                  decoration: InputDecoration(labelText: "Author"),
                ),
                TextField(
                  controller: totalCopiesController,
                  decoration: InputDecoration(labelText: "Avilable Copies"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Prepare data to update in Firebase RTDB.
                var updatedData = {
                  "name": nameController.text,
                  "author": authorController.text,
                  "copies":
                  int.tryParse(totalCopiesController.text) ?? 0,
                };

                DatabaseReference ref = FirebaseDatabase.instance
                    .ref()
                    .child("Books")
                    .child(widget.book_data.book_id);
                ref.update(updatedData).then((_) {
                  // Update local state to reflect the new details.
                  setState(() {
                    widget.book_data.name = nameController.text;
                    widget.book_data.author = authorController.text;
                    widget.book_data.total_copies =
                        int.tryParse(totalCopiesController.text) ?? 0;
                  });
                  Navigator.pop(context);
                }).catchError((error) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to update details: $error"),
                    ),
                  );
                });
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
}

class BookAssing_model{
  var stud_id,due_date,sname;
  BookAssing_model({required this.stud_id,required this.sname,required this.due_date});
}
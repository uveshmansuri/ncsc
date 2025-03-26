import 'package:NCSC/Services/Send_Notification.dart';
import 'package:NCSC/librarywhole/Library_DashBoard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
        title: Text("Assing Book"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Card(
                child: ListTile(
                  title: Text(
                    widget.book_data.name,
                    style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.black),
                  ),
                  subtitle: Text(
                    "${widget.book_data.author}\nDepartment:${widget.book_data.dept}",
                    style: TextStyle(fontSize:10,color: Colors.black87),
                  ),
                  trailing:IconButton(
                      onPressed: (){
                        showAssignBookDialog(context);
                      },
                      icon: Icon(Icons.assignment_turned_in_outlined)
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: assing_book_list.length,
                  itemBuilder: (context,i){
                    int daysLate=0;
                    Color? color=null;
                    bool notify=false;
                    DateTime currentDate = DateTime.now();
                    DateTime dueDate = DateFormat("yyyy-MM-dd").parse(assing_book_list[i].due_date);
                    if (currentDate.isAfter(dueDate)) {
                      daysLate = currentDate.difference(dueDate).inDays;
                      notify=true;
                      if(daysLate==0){
                        color=Colors.blueAccent;
                      }else{
                        color=Colors.redAccent;
                      }
                    }
                    print(daysLate);
                    var obj=assing_book_list[i];
                    return Card(
                      color: color,
                      child: ListTile(
                        leading: Text(obj.stud_id),
                        title: Text(obj.sname),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(obj.due_date),
                            if(notify)
                              IconButton(
                                  onPressed: (){
                                    Remainder_Student(obj.stud_id);
                                  },
                                  icon: Icon(Icons.notifications_on_sharp,color: Colors.white,),
                              ),
                          ],
                        ),
                        onTap: (){
                          book_return(i);
                        },
                        onLongPress: (){

                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAssignBookDialog(BuildContext context) {
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
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Text("Due Date:$formattedDate"),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      assing_toStudent(studentIdController.text,formattedDate);
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Assign'),
                  ),
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
      if(db.child("dept").value.toString()==widget.book_data.dept){
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book Assingend to Student")));
                fetch_assing_students();
              });
            });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can't assing book to Other Department Student")));
      }
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

  void Remainder_Student(String stud_id) async{
    var db=await FirebaseDatabase.instance.ref("Users/$stud_id/token").get();
    String token=db.value.toString();
    String msg="Return the Book";
    SendNotification.sendNotificationbyAPI(token: token, title: "Book Return Alert", body: msg);
  }
}

class BookAssing_model{
  var stud_id,due_date,sname;
  BookAssing_model({required this.stud_id,required this.sname,required this.due_date});
}
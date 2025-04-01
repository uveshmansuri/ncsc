import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'Assing_Book.dart';
import 'Pervie_Book.dart';

class Library_Main extends StatefulWidget {
  @override
  State<Library_Main> createState() => _Library_MainState();
}

class _Library_MainState extends State<Library_Main> {

  TextEditingController searchController = TextEditingController();

  List<String> dept_lst=[];
  String dept = 'All';
  String selectedDept="All";

  List<Map<String, dynamic>> booksData = [];

  List<books_model> books_list=[];
  List<books_model> temp_book_list=[];

  bool is_loading=true;

  String loading_msg="Loading Books Details";

  bool is_assinged=false;

  @override
  void initState() {
    super.initState();
    fetch_books();
    _fetch_dept();
  }

  void _fetch_dept() async{
    final db_ref=FirebaseDatabase.instance.ref("department");
    final snapshot=await db_ref.get();
    dept_lst.insert(0, "All");
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var dname=sp.child("department").value.toString();
        dept_lst.add(dname);
      }
    }
    setState(() {
    });
  }
  
  void fetch_books() async{
    books_list.clear();
    temp_book_list.clear();

    DatabaseReference ref = FirebaseDatabase.instance.ref("Books");

    ref.onValue.listen((event) {
      if (event.snapshot.exists) {
        books_list.clear();
        temp_book_list.clear();

        for (DataSnapshot sp in event.snapshot.children) {
          int copies = int.tryParse(sp.child("copies").value.toString()) ?? 0;

          var obj = books_model(
            book_id: sp.key ?? "",
            name: sp.child("name").value.toString(),
            author: sp.child("author").value.toString(),
            dept: sp.child("dept").value.toString(),
            assing_copies: sp.child("Assing").children.length,
            total_copies: copies,
          );

          books_list.add(obj);
          temp_book_list.add(obj);
        }

        setState(() {
          is_loading=false;
        });
      }
    });
  }

  void applyFilters() {
    List<books_model> filteredList = temp_book_list;
    if (dept != "All") {
      filteredList = filteredList.where((s) => s.dept == dept).toList();
    }

    if(is_assinged==true){
      filteredList=filteredList.where((s)=>s.assing_copies>0).toList();
    }

    String query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredList = filteredList.where((s) => s.name.toLowerCase().contains(query)).toList();
    }

    setState(() {
      books_list = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library Work Space"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) => applyFilters(),
                  decoration: InputDecoration(
                    labelText: "Search Book",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        applyFilters();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 30,),
                    Text("Select Department"),
                    SizedBox(width: 30,),
                    DropdownButton<String>(
                      value: dept,
                      hint: Text("Select Department"),
                      items: dept_lst
                          .map((group) =>
                          DropdownMenuItem<String>(
                            value: group,
                            child: Text(group),
                          ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          dept = value!;
                          selectedDept=dept;
                          applyFilters();
                          // if(dept=="All"){
                          // //   stud_list.clear();
                          // //   stud_list.addAll(temp_stud_list);
                          // //   setState(() {
                          // //     count=stud_list.length;
                          // //   });
                          //   applyFilters();
                          // }else{
                          //   //int index = dept_lst.indexOf(value!);
                          //   applyFilters();
                          // }
                        });
                      },
                    ),//For DEPT Filter
                  ],
                ),
                CheckboxListTile(
                    value: is_assinged,
                    title: Text("Assinged Books"),
                    onChanged: (val){
                      is_assinged=val!;
                      setState(() {});
                      applyFilters();
                    }
                ),
                SizedBox(height:10,),
                Expanded(
                  child: ListView.builder(
                    itemCount:books_list.length,
                    itemBuilder: (context,i){
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                        shadowColor: Colors.cyanAccent.shade200,
                        color: books_list[i].total_copies!=0?Colors.tealAccent.shade100:Colors.redAccent,
                        child: ListTile(
                          title: Text(
                            books_list[i].name,
                            style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.black),
                          ),
                          subtitle: Text(
                            "${books_list[i].author}\nDepartment:${books_list[i].dept}",
                            style: TextStyle(fontSize:10,color: Colors.black87),
                          ),
                          trailing: Text(
                            "Remaining Copies:${books_list[i].total_copies}\n"
                                "Assing Copies:${books_list[i].assing_copies}",
                            style: TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: Colors.black87),
                          ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>AssingBook(books_list[i])));
                          },
                          onLongPress: (){
                            delete_book_dialogue(i);
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            if(is_loading==true)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Dim background
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$loading_msg",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        // FAB icon animation
        backgroundColor: Colors.blue,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.upload_file_rounded,
            ),
            label: "Upload Excel",
            onTap: () async{
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: Text("Upload Excel flie of Book"),
                  content: Text("Formate of Excel File must be like this\nBook Id Book Name Author Total Copies Department"),
                  actions: [
                    TextButton(onPressed: (){
                      Navigator.pop(context);
                      pickExcelFile();
                    }, child: Text("Upload")),
                    TextButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: Text("Cancel")),
                  ],
                );
              });
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.book,
            ),
            label: "Add Book",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Book_Screen(dep_list: dept_lst,)));
            },
          ),
        ],
      ),
    );
  }

  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) return;

    Uint8List bytes = result.files.single.bytes!;
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> tempBooks = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      for (var row in sheet.rows.skip(1)) { // Skip headers
        String bookId = row[0]?.value.toString() ?? "";
        String name = row[1]?.value.toString() ?? "";
        String author = row[2]?.value.toString() ?? "";
        int copies = int.tryParse(row[3]?.value.toString() ?? "0") ?? 0;
        String dept = row[4]?.value.toString() ?? "";

        if (bookId.isNotEmpty) {
          tempBooks.add({
            "id": bookId,
            "name": name,
            "author": author,
            "copies": copies,
            "dept": dept,
          });
        }
      }
    }

    setState(() {
      booksData = tempBooks;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Preview(booksData)),
    );
  }

  void delete_book_dialogue(int i){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Confirm Book Delete"),
        content: Text("Do you Want to Remove '${books_list[i].name}' Book of '${books_list[i].author}'"),
        actions: [
          TextButton(onPressed: (){
            if(books_list[i].assing_copies!=0){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("You cant Remove this Book it's Assign to Students")),
              );
              Navigator.pop(context);
              return;
            }
            delete_book(books_list[i].book_id);
            Navigator.pop(context);
          }, child: Text("Confirm")),
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("Cancel")),
        ],
      );
    });
  }

  void delete_book(var book_id) async{
    await FirebaseDatabase.instance
        .ref("Books/$book_id").remove()
        .then((_){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Book Removed Successfully")),
          );
        })
        .catchError((err){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to Remove Book:$err")),
          );
        });
  }
}

class books_model{
  String book_id,name,author,dept;
  int total_copies;
  int assing_copies;
  var status;
  books_model({
    required this.book_id,required this.name,
    required this.author,required this.dept,
    required this.total_copies,
    required this.assing_copies,
    this.status
  });
}


class Add_Book_Screen extends StatefulWidget {
  final List<String> dep_list;
  Add_Book_Screen({Key? key, required this.dep_list});
  @override
  State<Add_Book_Screen> createState() => _Add_Book_ScreenState();
}

class _Add_Book_ScreenState extends State<Add_Book_Screen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _bookIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _totalCopiesController = TextEditingController();

  // Variable for selected department from the dropdown
  String? _selectedDept;

  bool _isLoading = false;

  // Function to upload book data to Firebase RTDB
  Future<void> uploadBookData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      DatabaseReference bookRef = FirebaseDatabase.instance
          .ref("Books/${_bookIdController.text.trim()}");
      try {
        await bookRef.set({
          "name": _nameController.text.trim(),
          "author": _authorController.text.trim(),
          "dept": _selectedDept,
          "copies": int.parse(_totalCopiesController.text.trim()),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Book data uploaded successfully")),
        );
        // Optionally clear the fields after upload
        _bookIdController.clear();
        _nameController.clear();
        _authorController.clear();
        _totalCopiesController.clear();
        setState(() {
          _selectedDept = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload book data: $error")),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Book"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Book ID Field
                TextFormField(
                  controller: _bookIdController,
                  decoration: InputDecoration(
                    labelText: "Book ID",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a book ID";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Book Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Book Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the book name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Author Field
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    labelText: "Author",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the author's name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Department Dropdown Field
                DropdownButtonFormField<String>(
                  value: _selectedDept,
                  decoration: InputDecoration(
                    labelText: "Department",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: widget.dep_list.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDept = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || _selectedDept=="All") {
                      return "Please select a department";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                // Total Copies Field
                TextFormField(
                  controller: _totalCopiesController,
                  decoration: InputDecoration(
                    labelText: "Total Copies",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the total copies";
                    }
                    if (int.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.0),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: uploadBookData,
                  icon: Icon(Icons.upload_file),
                  label: Text("Upload Book"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
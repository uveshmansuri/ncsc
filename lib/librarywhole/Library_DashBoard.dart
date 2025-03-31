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
        title: Text("Library DashBoard"),
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
            onTap: () {},
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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../librarywhole/Library_DashBoard.dart';

class Students_Library extends StatefulWidget {
  var dept;
  Students_Library({required this.dept});
  @override
  State<Students_Library> createState() => _Students_LibraryState();
}

class _Students_LibraryState extends State<Students_Library> {
  TextEditingController searchController = TextEditingController();

  List<books_model> books_list=[];

  List<books_model> temp_book_list=[];

  bool is_loading=true;

  String loading_msg="Loading Books Details";

  @override
  void initState() {
    super.initState();
    fetch_books();
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
        title: Text("NCSC Library"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height:10,),
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
                SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                    itemCount:books_list.length,
                    itemBuilder: (context,i){
                      return Card(
                        color: books_list[i].total_copies!=0?Colors.cyanAccent.shade100:Colors.redAccent,
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
                        ),
                      );
                    },
                  ),
                ),
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
    );
  }
}

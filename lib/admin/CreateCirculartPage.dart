import 'package:NCSC/admin/circular_preview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class CreateCircularPage extends StatefulWidget {
  @override
  State<CreateCircularPage> createState() => _CreateCircularPageState();
}

class _CreateCircularPageState extends State<CreateCircularPage> {
  
  final _formKey = GlobalKey<FormState>();

  TextEditingController txt_sub=TextEditingController();
  TextEditingController txt_description=TextEditingController();

  int flag=0;

  final db_ref=FirebaseDatabase.instance.ref("circulars");

  void _addSpaceAtCursor() {
    final text = txt_description.text;
    final selection = txt_description.selection;
    if (selection.start >= 0) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '\t\t\t\t\t',
      );
      txt_description.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    }
  }

  // Function to wrap selected text with specified formatting characters
  void _applyStyleToSelection(String prefix, String suffix) {
    final text = txt_description.text;
    final selection = txt_description.selection;

    if (selection.start >= 0 && selection.end > selection.start) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );

      txt_description.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + prefix.length + suffix.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Circular',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            children: [
                              Image.asset("assets/images/logo1.png",width: 100,height: 150,),
                              TextFormField(
                                controller: txt_sub,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.title_rounded),
                                  labelText: "Enter Subject of Circular",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter faculty id';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  FloatingActionButton(
                                    onPressed: ()=>_applyStyleToSelection("**","**"),
                                    child: Icon(Icons.format_bold_rounded),
                                  ),
                                  FloatingActionButton(
                                    onPressed: ()=>_applyStyleToSelection('*', '*'),
                                    child: Icon(Icons.format_italic_rounded),
                                  ),
                                  FloatingActionButton(
                                    onPressed: ()=>_applyStyleToSelection('__', '__'),
                                    child: Icon(Icons.format_underline_rounded),
                                  ),
                                  FloatingActionButton(
                                    onPressed: _addSpaceAtCursor,
                                    child: Icon(Icons.format_textdirection_l_to_r),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              TextFormField(
                                controller: txt_description,
                                maxLines: 15,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  height: 1.5, // Line height
                                ),
                                decoration: InputDecoration(
                                  labelText: "Enter Description",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Description';
                                  }
                                  return null;
                                },
                              //   onTap: (){
                              //     setState(() {
                              //       if(flag==0){
                              //         txt_description.text="\t\t\t\t\t\t\t";
                              //         flag++;
                              //       }
                              //     });
                              //   },
                              //   onChanged: (text) {
                              //   if (text.endsWith('\n')) {
                              //     txt_description.text = text + "\t\t\t\t\t\t\t";
                              //     txt_description.selection = TextSelection.fromPosition(
                              //       TextPosition(offset: txt_description.text.length),
                              //     );
                              //   }
                              // },
                              ),
                              SizedBox(height: 10,),
                              ElevatedButton(
                                  onPressed: () async{
                                    bool res;
                                    if (_formKey.currentState!.validate()){
                                      res=await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => circular_preview(txt_sub.text,txt_description.text)
                                          )
                                      );
                                      if(res=true){
                                        Navigator.pop(context,true);
                                      }
                                      //show_preview(context);
                                    }
                                  },
                                  child: Text("Post Circular")
                              ),
                            ],
                          ),
                        ),
                      )
                  )
              ),
            ]
        ),
      )
    );
  }
  // void show_preview(BuildContext ctx){
  //   String cname = "NARMADA COLLEGE OF SCIENCE & COMMERCE";
  //   String cloc = "Zadeshwar, Bharuch(Gujarat) 392011";
  //   String crr_date = DateFormat("dd.MM.yyyy").format(DateTime.now());
  //
  //   bool isFacultySelected = false;
  //   bool isStudentSelected = false;
  //
  //   showDialog(context: ctx, builder: (BuildContext ctx){
  //     return Expanded(
  //       child: SingleChildScrollView(
  //         child: AlertDialog(
  //           title: Text("Circular Preview"),
  //           content: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Center(child: Image.asset("assets/images/logo1.png",height: 200,width: 150,)),
  //                 Text(
  //                   cname,
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 Text(
  //                   cloc,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //                 SizedBox(height: 10),
  //                 Text(
  //                   "Date: $crr_date",
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                   ),
  //                 ),
  //                 Divider(thickness: 1, height: 20),
  //                 Center(
  //                   child: Text(
  //                     txt_sub.text,
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(height: 10),
  //                 Center(
  //                   child: Text(
  //                     txt_description.text,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ),
  //                 Row(
  //                   children: [
  //                     Checkbox(
  //                       value: isFacultySelected,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           isFacultySelected = value!;
  //                         });
  //                       },
  //                     ),
  //                     Text("Faculty"),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     Checkbox(
  //                       value: isStudentSelected,
  //                       onChanged: (value) {
  //                         setState(() {
  //                           isStudentSelected = value!;
  //                         });
  //                       },
  //                     ),
  //                     Text("Student"),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  // }
}
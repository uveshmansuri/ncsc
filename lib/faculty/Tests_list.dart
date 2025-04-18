import 'package:NCSC/faculty/CreateTest.dart';
import 'package:NCSC/faculty/Test_Report.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Test_list extends StatefulWidget{
  var sub,dept,sem,fid;
  Test_list({required this.sem,required this.dept,required this.sub,required this.fid});
  @override
  State<Test_list> createState() => _Test_listState();
}

class _Test_listState extends State<Test_list> {
  List<test_model> test_list=[];

  bool is_loading=true;
  bool is_avil=true;

  @override
  void initState() {
    super.initState();
    fetch_tests();
  }

  void fetch_tests() async{
    var ref = FirebaseDatabase.instance.ref("Test/${widget.dept}/${widget.sem}");
    var sp =await ref.orderByChild("sub").equalTo(widget.sub).get();
    if(!sp.exists){
      setState(() {
        is_loading=false;
        is_avil=false;
      });
    }
    await ref.orderByChild("sub").equalTo(widget.sub)
        .onChildAdded.listen(
            (event){
              if (event.snapshot.exists){
                DataSnapshot sp=event.snapshot;
                var id=sp.key;
                var title=sp.child("title").value.toString();
                var no=sp.child("no_ques").value.toString();
                var start=sp.child("starting").value.toString();
                var end=sp.child("ending").value.toString();
                var level=sp.child("level").value.toString();
                var time_per_que=sp.child("time_que").value.toString();
                test_list.add(test_model(
                    id: id, title: title, no: no, start: start, end: end,
                    level: level,time_que: time_per_que
                ));
                setState(() {
                  is_loading=false;
                  is_avil=true;
                });
              }
            }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tests"),
      ),

      body: Stack(
        children: [
          is_loading?
          Center(child: CircularProgressIndicator(),)
              :
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: ListView.builder(
                  itemCount: test_list.length,
                  itemBuilder: (context,i){
                    return Card(
                      elevation: 5,
                      shadowColor: Colors.tealAccent,
                      child: ListTile(
                        title: Text(
                          test_list[i].title,
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),
                        ),
                        subtitle: Text(
                          "Schedule:${test_list[i].start} to ${test_list[i].end}",
                          style: TextStyle(fontSize: 10,color: Colors.black45),
                        ),
                        trailing: Text(
                          "Total Questions:${test_list[i].no}\nLevel:${test_list[i].level}",
                          style: TextStyle(fontSize: 15,color: Colors.black45),
                        ),
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context)=>
                                      TestReportScreen(dept: widget.dept,sem: widget.sem,test_id: test_list[i].id,)
                              )
                          );
                        },
                      ),
                    );
                  }
              ),
            ),
          ),

          if(is_avil==false)
            Center(
              child: Text(
                "Test is Not Published Yet for This Subject, \nPublish it Now",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context)=>Createtest(
                    dept:widget.dept,
                    sem: widget.sem,
                    sub: widget.sub,
                    fid: widget.fid,
                  )
              )
          );
        },
        child: Icon(Icons.add_circle),
      ),
    );
  }
}

class test_model{
  var id,title,topics,no,start,end,level,time_que,sub;
  test_model({
    required this.id,required this.title,required this.no,
    this.start,this.end,this.time_que,this.level,this.topics,this.sub
  });
}
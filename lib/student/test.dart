import 'package:NCSC/faculty/Tests_list.dart';
import 'package:NCSC/student/Test_Screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:NCSC/faculty/Tests_list.dart';
import 'package:NCSC/student/Test_Screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TestPage extends StatefulWidget {
  var stud_id,dept,sem;
  TestPage({required this.stud_id,required this.dept,required this.sem});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<test_model> test_list=[];
  var test_result=null;

  bool is_avil=true;

  bool is_loading=true;

  @override
  void initState() {
    super.initState();
    fetch_test();
  }

  void fetch_test() async{
    var db=FirebaseDatabase.instance.ref("Test/${widget.dept}/${widget.sem}");
    var sp = await db.get();
    if(!sp.exists){
      setState(() {
        is_loading=false;
        is_avil=false;
      });
    }
    await db.onChildAdded.listen((event){
      if (event.snapshot.exists){
        DataSnapshot sp=event.snapshot;
        var id=sp.key;
        var title=sp.child("title").value.toString();
        var no=sp.child("no_ques").value.toString();
        var start=sp.child("starting").value.toString();
        var end=sp.child("ending").value.toString();
        var level=sp.child("level").value.toString();
        var time_per_que=sp.child("time_que").value.toString();
        var topics=sp.child("topics").value as List;
        var sub=sp.child("sub").value.toString();
        if(sp.child("${sp.key}/Report/${widget.stud_id}").exists){
          test_result=sp.child("Report/${widget.stud_id}").child("result").value.toString();
        }
        test_list.add(test_model(
            id: id, title: title, no: no, start: start, end: end,
            level: level,time_que: time_per_que,topics: topics,sub: sub
        ));
        setState(() {
          print(test_list.length);
          if(test_list.isEmpty){
            is_avil=false;
          }
          is_loading=false;
        });
      }
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
              child: ListView.builder(
                  itemCount: test_list.length,
                  itemBuilder: (context,i){
                    return Card(
                      elevation: 5,
                      shadowColor: Colors.tealAccent,
                      child: ListTile(
                        title: Text(
                            "Subject:"+test_list[i].sub,
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.blue)
                        ),
                        subtitle: Text(
                          test_list[i].title,
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),
                        ),
                        trailing: Text(
                          "Questions:${test_list[i].no}",
                          style: TextStyle(fontSize: 15,color: Colors.black45),
                        ),
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context)=>Test_details(
                                      widget.stud_id,test_list[i],widget.dept,widget.sem,test_result
                                  )
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
                "Test is Not Published Yet",
                style: TextStyle(color: Colors.black,fontSize: 20),
              ),
            ),
        ],
      ),
    );
  }
}

class Test_details extends StatefulWidget{
  test_model obj;
  var stud_id,dept,sem;
  var test_result;
  Test_details(this.stud_id,this.obj,this.dept,this.sem,this.test_result);

  @override
  State<Test_details> createState() => _Test_detailsState();
}

class _Test_detailsState extends State<Test_details> {
  List topics=[];

  bool isloading=false;

  String msg="Loading Test Questions";

  @override
  void initState() {
    super.initState();
    topics=widget.obj.topics as List;
    if(widget.test_result==null)
      fetch_test_res();
    setState(() {});
  }

  void fetch_test_res() async{
    var db=await FirebaseDatabase.instance
        .ref("Test/${widget.dept}/${widget.sem}/${widget.obj.id}/Report/${widget.stud_id}").get();
    if(db.exists){
      setState(() {
        widget.test_result=db.child("result").value.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isloading,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${widget.obj.sub}:${widget.obj.title} "),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.assignment,size: 40,color: Colors.blueAccent,),
                    title: Text("Topics",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                    trailing: Text("Total Questions:${widget.obj.no}"),
                  ),
                  Text("Schedule:${widget.obj.start} to ${widget.obj.end}",style: TextStyle(color: Colors.black54),),
                  SizedBox(height: 2,),
                  Divider(color: Colors.black45,thickness: 2,),
                  SizedBox(height: 2,),
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                        itemCount: topics.length,
                        itemBuilder: (context,i){
                          return Card(
                            elevation: 5,
                            shadowColor: Colors.tealAccent,
                            margin: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                            child: ListTile(
                              title: Text(topics[i]),
                            ),
                          );
                        }
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(color: Colors.black45,thickness: 2,),
                  widget.test_result==null
                      ?
                  Expanded(
                    child: Column(
                      children: [
                        ElevatedButton(onPressed: (){
                          DateTime start_date_time = DateTime.parse(widget.obj.start);
                          DateTime end_date_time = DateTime.parse(widget.obj.end);
                          DateTime currentDateTime = DateTime.now();
                          if(currentDateTime.isBefore(start_date_time)){
                            Fluttertoast.showToast(msg: "Test is not Started Yet");
                          }else if(currentDateTime.isAfter(end_date_time)){
                            Fluttertoast.showToast(msg: "Test is Expired");
                          }else{
                            generate_ques();
                          }
                        }, child: Text("Start Test")),
                      ],
                    ),
                  )
                      :
                  Expanded(
                    child: build_result()
                  ),
                ],
              ),
            ),
            if(isloading==true)
              build_indicator()
          ],
        ),
      ),
    );
  }

  String get_query(){
    var sub_name=widget.obj.sub;
    var level=widget.obj.level;
    var all_topics="";
    for(var i in topics){
      all_topics+=("$i\n");
    }
    return "Give me total 10"+
        "question of " +
        sub_name +
        " of deficulty "+ level+
        " level questions "+
        " include given topics:\n($all_topics)"+
        " It should generate single string containing all questions with 4 unique option and also" +
        " add correct option " +
        "the generated string is into given formate " +
        "question###option1###option2###option3###option4###correct_option~=~=" +
        "each set is separeted by ~=~=" +
        "and inside set seperate questions and options with ### " +
        "also each questions and options are unique " +
        "the correct options position varies in between option1 to option4 " +
        " also don't put correct option continulesly at same position in row or 2 times" +
        "use seperators properly " +
        "and do't put any headers or extra garbage text in resopnse " +
        "also ensure that in correct option which is present in between option1 to option4 " +
        "put correct option do't put correct option's position " +
        "and put all things properly";
  }

  void generate_ques() async{
    var key="AIzaSyC9KMLHWS9IBy3ZqRTuarkbA1L085JxWcQ";
    var prompt=get_query();
    List<mcq_model> mcq_list=[];
    int no_ques=int.parse(widget.obj.no);

    String res="";

    for(int i=10;i<=no_ques;i+=10){
      try {
        setState(() {
          isloading=true;
        });
        final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: key);
        if(!res.isEmpty){
          prompt+=" also don't repeat below \n${res}";
        }
        final content = [Content.text(prompt)];
        //print("Getting Response");
        final response = await model.generateContent(content);
        res+= "${response.text}";
        List<String> lines=response.text!.split("~=~=");
        for(var len in lines){
          List<String> que_content=len.split("###");
          if(que_content.length!=6){
            Fluttertoast.showToast(msg: "Something went wrong!!!\nPlease try Again Later!!!");
            setState(() {
              isloading=false;
            });
            break;
          }
          mcq_list.add(mcq_model(
              quetion: que_content[0], op1: que_content[1],
              op2: que_content[2], op3: que_content[3], op4: que_content[4],
              corr_op: que_content[5]
          ));
        }
      }
      on Exception catch (e) {
        setState(() {
          isloading=false;
        });
        Fluttertoast.showToast(msg: e.toString());
        //print(e.toString());
      }
    }

    if(mcq_list.length==no_ques){
      var result=await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context)=>TestScreen(
                  stud_id: widget.stud_id, mcq_list: mcq_list, test_obj: widget.obj
              )
          )
      );

      if(result==null || result==false){
        setState(() {
          msg="Uploading Result";
        });
        await FirebaseDatabase.instance
            .ref("Test/${widget.dept}/${widget.sem}/${widget.obj.id}/Report")
            .child(widget.stud_id)
            .set({"result":"Terminated"})
            .then((_){
          Fluttertoast.showToast(msg: "Test Terminated");
        })
            .catchError((err){
          Fluttertoast.showToast(msg: err.toString());
        });
        setState(() {
          widget.test_result="Terminated";
          isloading=false;
        });
      }

      else{
        Fluttertoast.showToast(msg: "${result[0]}/${result[1]}");
        await FirebaseDatabase.instance
            .ref("Test/${widget.dept}/${widget.sem}/${widget.obj.id}/Report")
            .child("${widget.stud_id}")
            .set({"result":"${result[0]} out of ${result[1]}"})
            .then((_){
          Fluttertoast.showToast(msg: "Test Finished\nScore:${result[0]} out of ${result[1]}");
        })
            .catchError((err){
          Fluttertoast.showToast(msg: err.toString());
        });
        setState(() {
          widget.test_result="${result[0]} out of ${result[1]}";
          isloading=false;
        });
      }
    }

    else{
      setState(() {
        isloading=false;
      });
      Fluttertoast.showToast(msg: "Something went wrong!!\nPlease try Again Later!!");
    }

    //   print(mcq_list.length);
    //   // var model=AzureAIChat();
    //   // var response=await model.getChatResponse(prompt);
    //   //   List<String> lines=response.split("~=~=");
    //   //   for(var len in lines){
    //   //     List<String> que_content=len.split("###");
    //   //     print("Q."+que_content[0]);
    //   //     print("A."+que_content[1]);
    //   //     print("B."+que_content[2]);
    //   //     print("C."+que_content[3]);
    //   //     print("D."+que_content[4]);
    //   //     print("Right."+que_content[5]);
    //   //     mcq_list.add(mcq_model(
    //   //             quetion: que_content[0], op1: que_content[1],
    //   //             op2: que_content[2], op3: que_content[3], op4: que_content[4],
    //   //             corr_op: que_content[5]
    //   //     ));
    //   //   }
    //   //   print(lines.length);
    //   //print(prompt);
    // }
    //
  }

  Widget build_result(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
            elevation: 5,
            shadowColor: Colors.tealAccent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.receipt_sharp,color: Colors.blueAccent,size: 30,),
                  SizedBox(width: 10,),
                  Text(
                    "Result of Test is ${widget.test_result}",
                    style: TextStyle(fontSize: 15,color: Colors.black87,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }

  build_indicator(){
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  msg,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                )
              ]
          ),
        ),
      ),
    );
  }
}

class mcq_model{
  var quetion,op1,op2,op3,op4,corr_op;
  mcq_model({
    required this.quetion,
    required this.op1, required this.op2,
    required this.op3, required this.op4,
    required this.corr_op,
  });
}

// class AzureAIChat {
//   //final String apiKey = "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";
//   final String apiKey ="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";
//   final String endpoint = "https://models.inference.ai.azure.com";
//   //var point= "https://models.inference.ai.azure.com/openai/deployments/gpt-4o-deployment/chat/completions?api-version=2024-02-01";
//   final String model = "gpt-4o";
//
//   Future<String> getChatResponse(String userMessage) async {
//     final url = Uri.parse("$endpoint/v1/chat/completions");
//     //final url=Uri.parse("$point");
//     final headers = {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $apiKey",
//     };
//
//     final body = jsonEncode({
//       "model": model,
//       "messages": [
//         {"role": "system", "content": ""},
//         {"role": "user", "content": userMessage}
//       ]
//     });
//
//     final response = await http.post(url, headers: headers, body: body);
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['choices'][0]['message']['content'];
//     } else {
//       throw Exception("Failed to load response: ${response.body}");
//     }
//   }
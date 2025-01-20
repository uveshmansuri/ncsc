import 'package:NCSC/admin/CreateCirculartPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Circulars extends StatefulWidget{
  @override
  State<Circulars> createState() => _CircularsState();
}

class _CircularsState extends State<Circulars> {
  final db_ref=FirebaseDatabase.instance.ref("Circulars");
  final List<circular_model> _circular=[];
  @override
  void initState() {
    super.initState();
    fetch_circulars();
  }

  void fetch_circulars() async{
    _circular.clear();
    final snapshot=await db_ref.get();
    if(snapshot.exists){
      for(DataSnapshot sp in snapshot.children){
        var id=sp.key.toString();
        var title=sp.child("title").value.toString();
        var description=sp.child("description").value.toString();
        var date=sp.child("published_date").value.toString();
        _circular.insert(0,circular_model(title, description, date,id));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Circulars",
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0), // Center of the gradient
            radius: 1.0, // Spread of the gradient
            colors: [
              Color(0xffffffff),
              Color(0xFFE0F7FA),
            ],
            stops: [0.3,1.0],
          ),
        ),
        child: Center(
          child: _circular.isEmpty
              ? Center(
            child: Container(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                color: Colors.blue,
                backgroundColor: Colors.grey,
                strokeWidth: 5.0,
              ),
            ),
          ) 
              :  Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: _circular.length,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                        child: Card(
                          color: Color(0xFFf0f9f0),
                          shadowColor: Colors.lightBlueAccent,
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(Icons.notifications_sharp,size:30,color: Colors.lightBlue,),
                            title: Text(_circular[index].title,
                                style: TextStyle(
                                    color: Colors.lightBlue,fontWeight: FontWeight.bold,fontSize: 20
                                ),
                            ),
                            subtitle: Text(_circular[index].description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_circular[index].date),
                                IconButton(
                                  icon:Icon(
                                    Icons.delete_forever_sharp,
                                    color: Colors.red,size: 25,
                                  ),
                                  onPressed: (){
                                    showDialog(context: context, builder: (ctx){
                                      return AlertDialog(
                                        title: Text("NCSC"),
                                        content: Text("Do you Want to delete Circular?"),
                                        actions: [
                                          TextButton(onPressed: (){
                                            Navigator.pop(ctx);
                                          }, child: Text("No"),),
                                          TextButton(onPressed: () async{
                                            await db_ref.child(_circular[index].id)
                                                .remove()
                                                .then((_){
                                              Fluttertoast.showToast(msg: "Circular Deleted");
                                              fetch_circulars();
                                              Navigator.pop(ctx);
                                            })
                                                .catchError((error){
                                              Fluttertoast.showToast(msg: "${error.toString()}");
                                              Navigator.pop(ctx);
                                            });
                                          }, child: Text("Yes")),
                                        ],
                                      );
                                    });

                                  },)
                              ],
                            ),
                          ),
                        ),
                      );
                }),
              ),
            ],
          ),
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            bool res=await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CreateCircularPage()));
            if(res){
              fetch_circulars();
            }
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        )
    );
  }
}

class circular_model{
  String title,description,date,id;
  circular_model(this.title,this.description,this.date,this.id);
}
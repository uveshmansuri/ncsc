import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker_web/image_picker_web.dart';

class Stud_AD extends StatefulWidget{
  var stud_id,sname,dept,sem,email;
  String? url;
  Stud_AD({required this.stud_id,required this.sname,required this.email,required this.dept,required this.sem,this.url});

  @override
  State<Stud_AD> createState() => _Stud_ADState();
}

class _Stud_ADState extends State<Stud_AD> {
  bool is_uploading=false;
  String _response="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student's Detail"),
      ),
      body: Center(
        child: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0), // Center of the gradient
                radius: 1.0, // Spread of the gradient
                colors: [
                  Color(0xFFE0F7FA),
                  Color(0xffd1fbff),
                ],
                stops: [0.3,1.0],
              )
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Material(
                            elevation: 15,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(360),
                              side: BorderSide(
                                color: Colors.cyan, // Border color
                                width: 2,// Border width
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(360),
                                child:
                                (widget.url != null && widget.url!.isNotEmpty)
                                    ?
                                Image.network(
                                  widget.url!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                    :
                                Image.asset(
                                    "assets/images/student_profile.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                )
                            )
                          ),
                          GestureDetector(
                            onTap: ()=>_pickImage(),
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 20,
                              child: Icon(Icons.edit, color: Colors.white, size: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                    build_item(widget.stud_id, Icons.badge_outlined),
                    build_item(widget.sname, Icons.account_circle),
                    build_item(widget.email, Icons.email_rounded),
                    build_item(widget.dept, Icons.apartment_sharp),
                    build_item("Semester:"+widget.sem, Icons.school_outlined),
                  ],
                ),
              ),
              if(is_uploading==true)
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
                            "$_response",
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
      ),
    );
  }
  Widget build_item(String value,IconData ic){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      child: Card(
        elevation: 10,
        shadowColor: Colors.lightBlueAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9,vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(ic,color: Colors.cyan,size: 30,),
              SizedBox(width: 10,),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(value,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void pick_img() async{
    File? _image;
    final ImagePicker _picker = ImagePicker();
    var stud_id=widget.stud_id;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    if (_image == null) return;
    try{
      //print("Uplading...");
      setState(() {
        //get_data_flag=false;
      });
      var fileName="students_images/img${stud_id}.png";
      //print(fileName);
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask=storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseDatabase.instance.ref("Students/${stud_id}").update({
        "url":downloadUrl
      });
      setState(() {
        widget.url=downloadUrl;
        Fluttertoast.showToast(msg: "Image Uploaded");
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }finally{
      setState(() {
        //get_data_flag=true;
      });
    }
  }

  Future<void> _pickImage() async {
    Uint8List? _imageBytes;
    File? _imageFile;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _uploadImage(await image.readAsBytes(),_imageFile);
    }
    // if (kIsWeb) {
    //   // Web Image Picker
    //   final image = await ImagePickerWeb.getImageAsBytes();
    //   if (image != null) {
    //     setState(() {
    //       _imageBytes = image;
    //     });
    //     await _uploadImage(image);
    //   }
    // } else {
    //
    // }
  }

  Future<void> _uploadImage(Uint8List imageBytes,File? _image) async {
    setState(() {
      is_uploading=true;
      _response = "Preparing...";
    });
    print("p..");
    var uri = Uri.parse('http://192.168.130.172:8000/encode');
    List<dynamic>? _faceEncodings;
    print("Starting....");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'face.png'));
    print("Preparing.....");
    try {
      setState(() {
        _response="Getting Encodings......";
      });
      print("Getting Encodings......");
      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      var decodedData = jsonDecode(responseData);

        if(response.statusCode == 200){
          _faceEncodings = decodedData['encodings'];
          print("Len:${_faceEncodings?.length}");

          if(_faceEncodings?.length==null){
            setState(() {
             is_uploading=false;
            });
            Fluttertoast.showToast(msg: "Uploading Failed\n${decodedData['message']}");
            return;
          }
          if(_faceEncodings!.length>1){
            setState(() {
              is_uploading=false;
            });
            Fluttertoast.showToast(msg: "Uploading Failed\nMultiple Faces Detected");
            return;
          }

          var fileName="students_images/img${widget.stud_id}.png";

          setState(() {
            _response="Uploading Image and Face Encodings......";
          });

          Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask=storageRef.putFile(_image!);

          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          await FirebaseDatabase.instance.ref("Students")
              .child(widget.stud_id)
              .update({
                "url":downloadUrl,
                "encoding": _faceEncodings?[0]
              }).then((_){
                setState(() {
                  widget.url=downloadUrl;
                });
                _response ="Task Completed";
                Fluttertoast.showToast(msg: "Image Successfully Uploaded with Encodings");
              }).catchError((err){
                _response =err.toString();
              });
        }
        else{
          setState(() {
            is_uploading=false;
            //_response ="Error: ${decodedData['message']}";
          });
          Fluttertoast.showToast(msg: "Error: ${decodedData['message']}");
        }
    } catch (e) {
      setState(() {
        is_uploading=false;
        //print(e.toString());
        //_response = "Failed to connect to server";
      });
      Fluttertoast.showToast(msg: "Failed to connect to server");
    }finally{
      setState(() {
        is_uploading=false;
        //_response="Image Successfully Uploaded with Encodings";
        //Fluttertoast.showToast(msg: "Image Successfully Uploaded with Encodings");
      });
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:NCSC/admin/students.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'attendancetake.dart';
import 'mark_attendance.dart';

class Live_Attend extends StatefulWidget {
  var dept, sem, sub;
  final List<students> stud_lst;

  Live_Attend(this.dept, this.sem, this.sub, this.stud_lst);

  @override
  State<Live_Attend> createState() => _Live_AttendState();
}

class _Live_AttendState extends State<Live_Attend> {
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  late IOWebSocketChannel _channel;
  Uint8List? _processedFrame;
  bool _isStreaming = false;
  int _selectedCameraIndex = 0;
  Timer? _timer;
  String _reportText = "";
  final String serverIp = "192.168.1.167";      //Server IP [IPv4 Adddress WIFI of Laptop]
  bool _fetching=false;

  @override
  void initState() {
    super.initState();
    start_attendance();
  }

  void start_attendance() async{
    for (students st in widget.stud_lst) {
      if (st.stud_id!=null && st.encodings != null && st.encodings!.isNotEmpty) {
        List<double> encodedList = (st.encodings as List).map((e) => (e as num).toDouble()).toList();
        _sendEncodings(st.stud_id,st.stud_name, encodedList);
      }
    }
    await _initializeCamera();
    _connectWebSocket();
    _startStreaming();
  }

  Future<void> _sendEncodings(String sid,String name, List<double> encoding) async {
    try {
      final url = Uri.parse("http://$serverIp:8000/get_encodings");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"stud_id":sid,"name": name, "encoding": encoding}),
      );
      if (response.statusCode == 200) {
        print("Encodings sent successfully: ${response.body}");
      } else {
        print("Error sending encodings: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception in _sendEncodings: $e");
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
        _cameras[_selectedCameraIndex], ResolutionPreset.medium);

    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _cameraController.dispose();
    await _initializeCamera();
  }

  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect("ws://$serverIp:8000/ws");
      _channel.stream.listen((data) {
        setState(() {
          if (data is String) {
            _processedFrame = Uint8List.fromList(utf8.encode(data));
          } else if (data is List<int>) {
            _processedFrame = Uint8List.fromList(data);
          }
        });
      }, onError: (error) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "WebSocket error: $error");
        print("WebSocket error: $error");
      }, onDone: () {
        print("WebSocket connection closed.");
      });
    } on Exception catch (e) {

    }
  }

  void _startStreaming() {
    if (!_cameraController.value.isInitialized) return;
    _isStreaming = true;
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      if (!_isStreaming) {
        timer.cancel();
        return;
      }
      try {
        XFile image = await _cameraController.takePicture();
        Uint8List bytes = await image.readAsBytes();
        _channel.sink.add(bytes);
      } catch (e) {
        print("Error capturing image: $e");
      }
    });
  }

  Future<void> _stopStreaming() async {
    setState(() {
      _isStreaming = false;
    });
    _timer?.cancel();
    _channel.sink.close();
    try {
      List<dynamic> pr_ids=[];
      List<stud_attent_list> sa_list=[];
      setState(() {
        _fetching=true;
        _reportText="Fetching Present Students......";
      });
      final report = await _getReport();
      setState(() {
        pr_ids.addAll(report['present']);
        for (students st in widget.stud_lst){
          if(pr_ids.contains(st.stud_id)){
            sa_list.add(stud_attent_list(id: st.stud_id, name: st.stud_name, isChecked: true));
          }else{
            sa_list.add(stud_attent_list(id: st.stud_id, name: st.stud_name,isChecked: false));
          }
        }
        // _reportText =
        // "Present: ${report['present'] ?? 0}\nAbsent: ${report['absent'] ?? 0} ${report['present'].runtimeType} ${sa_list.length}";
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>mark_attend.from_livefeed(widget.sub,sa_list)));
    } catch (e) {
      print("Error fetching report: $e");
      setState(() {
        _reportText = "Error retrieving report.";
      });
    }
  }

  Future<Map<String,dynamic>> _getReport() async {
    try {
      final url = Uri.parse("http://$serverIp:8000/report");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch report: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Exception in _getReport: $e");
      return {};
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _channel.sink.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Face Recognition Attendance")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isStreaming?Expanded(
              child: _processedFrame == null
                  ? CameraPreview(_cameraController)
                  : Image.memory(_processedFrame!),
            ):CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(_reportText, style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ElevatedButton(
                //   onPressed: _startStreaming,
                //   child: Text("Start"),
                // ),
                if(_fetching==false)
                  ElevatedButton(
                  onPressed: _stopStreaming,
                  child: Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _switchCamera,
        child: Icon(Icons.switch_camera),
      ),
    );
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import 'attendancetake.dart';
import 'mark_attendance.dart';

class Live_feed_web extends StatefulWidget{
  var dept, sem, sub;
  final List<students> stud_lst;

  Live_feed_web(this.dept, this.sem, this.sub, this.stud_lst);
  @override
  State<Live_feed_web> createState() => _Live_feed_webState();

  void export_excel_file_web(var excelBytes){
    final blob = html.Blob([Uint8List.fromList(excelBytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "$sub AttendanceSheet.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

class _Live_feed_webState extends State<Live_feed_web> {
  WebSocketChannel? _channel;
  Uint8List? _currentImage;
  List<String> presentStudents = [];
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvas;
  Timer? _timer;
  bool _isProcessingFrame = false;
  String _reportText="";
  final String serverIp = "127.0.0.1";
  //final String serverIp = "192.168.1.177";
  html.MediaStream? _mediaStream;

  @override
  void initState() {
    // TODO: implement initState
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
    await _initCamera();
    _connectToWebSocket();
    _captureAndSendFrameonWeb();
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

  Future<void> _initCamera() async {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.visibility = 'hidden';

    _canvas = html.CanvasElement(width: 1080, height: 720)
      ..style.visibility = 'hidden';

    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw Exception("Media devices not supported");
      }
      _mediaStream = await mediaDevices.getUserMedia({'video': {'width': 1080, 'height': 720}});
      // Request camera permissions
      if (mediaDevices == null) {
        throw Exception("Media devices not supported");
      }
      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': {'width': 1080, 'height': 720}});
      _videoElement!.srcObject = stream;
      html.document.body!.append(_videoElement!);
      html.document.body!.append(_canvas!);


      _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        _captureAndSendFrameonWeb();
      });
    } catch (e) {
      print('Error accessing camera: $e');
    }
  }

  void _captureAndSendFrameonWeb() {
    if (_videoElement == null || _canvas == null || _isProcessingFrame) return;
    _isProcessingFrame = true;
    final context = _canvas!.context2D as html.CanvasRenderingContext2D;
    context.drawImage(_videoElement!, 0, 0);

    _canvas!.toBlob('image/jpeg').then((blob) {
      if (blob == null) {
        _isProcessingFrame = false;
        return;
      }
      final reader = html.FileReader();

      reader.onLoadEnd.listen((_) {
        if (reader.result != null) {
          try {
            final bytes = Uint8List.fromList(reader.result as List<int>);
            _channel!.sink.add(bytes);
          } catch (e) {
            print('Error sending frame: $e');
          }
        }
        _isProcessingFrame = false;
      });
      reader.readAsArrayBuffer(blob);
    }).catchError((error) {
      print('Error converting canvas to blob: $error');
      _isProcessingFrame = false;
    });
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$serverIp:8000/ws'),
      //Uri.parse('ws://192.168.11.69:8000/ws'),
    );
    _channel!.stream.listen(
          (data) {
        if (data is Uint8List) {
          setState(() => _currentImage = data);
        }
      },
      onError: (error) => print('WebSocket error: $error'),
    );
  }

  Future<void> _stopStreaming() async {
    setState(() {
      if (_mediaStream != null) {
        _mediaStream!.getTracks().forEach((track) {
          //track.stop();
        });
      }
    });

    _channel?.sink.close();

    _timer?.cancel();
    _videoElement?.remove();
    _canvas?.remove();
    try {
      List<dynamic> pr_ids=[];
      List<stud_attent_list> sa_list=[];
      setState(() {
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
    _timer?.cancel();
    _channel?.sink.close();
    _videoElement?.remove();
    _canvas?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Recognition Attendance')),
      body: Column(
        children: [
          Expanded(
            child: _currentImage != null
                ? Image.memory(_currentImage!, fit: BoxFit.contain)
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton:
      FloatingActionButton(onPressed: _stopStreaming,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.stop),
            Text("Stop")
        ],
      ),),
    );
  }
}
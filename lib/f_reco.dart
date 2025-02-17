import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

class FaceRecognitionScreen extends StatefulWidget {
  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  WebSocketChannel? _channel;
  Uint8List? _currentImage;
  List<String> presentStudents = [];
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvas;
  Timer? _timer;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _connectToWebSocket();
  }

  Future<void> _initCamera() async {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.visibility = 'hidden';

    _canvas = html.CanvasElement(width: 640, height: 440)
      ..style.visibility = 'hidden';

    try {
      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': {'width': 640, 'height': 440}});
      _videoElement!.srcObject = stream;
      html.document.body!.append(_videoElement!);
      html.document.body!.append(_canvas!);


      _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        _captureAndSendFrame();
      });
    } catch (e) {
      print('Error accessing camera: $e');
    }
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.169:8000/ws'),
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

  void _captureAndSendFrame() {
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

  Future<void> _getPresentStudents() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.169:8000/present_students'));
      if (response.statusCode == 200) {
        setState(() {
          presentStudents = (json.decode(response.body)['Present_Students'] as List)
              .map((e) => e.toString())
              .toList();
          _timer?.cancel();
          _channel?.sink.close();
          _videoElement?.remove();
          _canvas?.remove();
        });
      }
    } on Exception catch (e) {
      print(e.toString());
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
          ElevatedButton(
            onPressed: _getPresentStudents,
            child: Text('Refresh Attendance List'),
          ),
          if (presentStudents.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: presentStudents.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(presentStudents[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
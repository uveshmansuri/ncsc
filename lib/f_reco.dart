import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

// The camera package is only used on mobile.
import "package:camera/camera.dart";

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

  // Variables for the mobile implementation.
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    if(kIsWeb){
      _initCamera();
    }else{
      _initCameraMobile();
    }
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
      // Request camera permissions
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw Exception("Media devices not supported");
      }
      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': {'width': 640, 'height': 440}});
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
      //Uri.parse('ws://127.0.0.1:8000/ws'),
      Uri.parse('ws://192.168.11.69:8000/ws'),
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

  // Mobile Implementation
  Future<void> _initCameraMobile() async {
    try {
      // Retrieve the available cameras on the device.
      final cameras = await availableCameras();
      final camera = cameras.first; // You might choose a different camera if needed.
      _cameraController = CameraController(camera, ResolutionPreset.low, enableAudio: false);
      await _cameraController!.initialize();

      // Periodically capture a still image every second.
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        if (_isProcessingFrame || !_cameraController!.value.isInitialized) return;
        _isProcessingFrame = true;
        try {
          // Capture a still picture.
          final XFile picture = await _cameraController!.takePicture();
          final bytes = await picture.readAsBytes();
          _channel?.sink.add(bytes);
        } catch (e) {
          print('Error capturing mobile frame: $e');
        }
        _isProcessingFrame = false;
      });
    } catch (e) {
      print('Error initializing mobile camera: $e');
    }
  }

  Future<void> _getPresentStudents() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.11.69:8000/present_students'));
      if (response.statusCode == 200) {
        setState(() {
          presentStudents = (json.decode(response.body)['Present_Students'] as List)
              .map((e) => e.toString())
              .toList();
          _timer?.cancel();
          _channel?.sink.close();
          if (kIsWeb) {
            _videoElement?.remove();
            _canvas?.remove();
          } else {
            _cameraController?.dispose();
          }
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
    if (kIsWeb) {
      _videoElement?.remove();
      _canvas?.remove();
    } else {
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Recognition Attendance')),
      body: Column(
        children: [
          !kIsWeb && _cameraController != null?
          Offstage(
              offstage: true,
              child: SizedBox(
                width: 1,
                height: 1,
                child: CameraPreview(_cameraController!),
              ),
            ):
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
          // For mobile, include a hidden CameraPreview to keep the camera active.
        ],
      ),
    );
  }
}
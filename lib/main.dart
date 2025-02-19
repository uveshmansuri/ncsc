import 'package:NCSC/admin/students.dart';
import 'package:NCSC/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'DBADashboard.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MY_APP());
}

class MY_APP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NCSC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DBA_Dashboard()
    );
  }
}
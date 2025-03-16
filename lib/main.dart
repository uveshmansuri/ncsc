import 'package:NCSC/admin/students.dart';
import 'package:NCSC/faculty/faculty_home.dart';
import 'package:NCSC/splash.dart';
import 'package:NCSC/student/test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'Conectivity_Check/controller.dart';
import 'DBADashboard.dart';
import 'faculty/Subject_List_Faculty.dart';
import 'faculty/main_faculty.dart';
import 'firebase_options.dart';
import 'nonteachingdashboard/notesforall.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MY_APP());
  Get.put(InternetController(),permanent: true);
}

class MY_APP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NCSC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: splash()
    );
  }
}
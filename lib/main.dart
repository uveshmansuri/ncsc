import 'package:NCSC/email_verification.dart';
import 'package:NCSC/splash.dart';
import 'package:NCSC/admin/create_faculty.dart';
import 'package:NCSC/library/AvailableBooksScreen.dart';
import 'package:NCSC/student/main_student.dart';
import 'package:NCSC/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'faculty/main_faculty.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    //options: DefaultFirebaseOptions.android
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NCSC',
      theme: AppTheme.light,       // Light theme
      themeMode: ThemeMode.system, // Automatically follow system theme
      home:  splash(),
     // home: DashboardPage(),
      // Your login screen
    );
  }
}




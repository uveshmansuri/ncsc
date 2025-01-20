import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'EnhancedDBADashboard.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(DBADashboardApp());
}

class DBADashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enhanced DBA Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EnhancedDBADashboard(), // Call the separated widget here
    );
  }
}

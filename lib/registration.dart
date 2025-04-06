import 'package:NCSC/admin/admin_portal.dart';
import 'package:NCSC/email_verification.dart';
import 'package:NCSC/faculty/main_faculty.dart';
import 'package:NCSC/login.dart';
import 'package:NCSC/student/main_student.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Registration extends StatefulWidget {
  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with SingleTickerProviderStateMixin {
  TextEditingController userTextController = TextEditingController();
  TextEditingController passTextController = TextEditingController();
  TextEditingController confirmPassTextController = TextEditingController();

  bool passwordVisibility = true;
  bool confirmPassVisibility = true;
  final _auth = FirebaseAuth.instance;

  bool loading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Clear text fields on tab change
        userTextController.clear();
        passTextController.clear();
        confirmPassTextController.clear();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    userTextController.dispose();
    passTextController.dispose();
    confirmPassTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Disable back button while loading
      onWillPop: () async => !loading,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xffF0F9F0),
            title: Text(
              "Registration",
              style: TextStyle(
                  color: Color(0xff0033ff),
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelStyle:
              TextStyle(fontSize: 20.0, color: Colors.lightBlue),
              unselectedLabelStyle:
              TextStyle(fontSize: 15.0, color: Colors.grey),
              tabs: [
                Tab(text: "Faculty"),
                Tab(text: "Student"),
              ],
            ),
          ),
          body: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                // Disable swiping when loading
                physics: loading
                    ? NeverScrollableScrollPhysics()
                    : AlwaysScrollableScrollPhysics(),
                children: [
                  buildRegistrationForm("Faculty"),
                  buildRegistrationForm("Student"),
                ],
              ),
              if (loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRegistrationForm(String role) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Card(
            color: Color(0xfff0f9f0),
            elevation: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        role.toLowerCase() == "faculty"
                            ? "assets/images/faculty_icon.png"
                            : "assets/images/student_profile.png",
                        height: 75,
                        width: 75,
                      ),
                      SizedBox(width: 30),
                      Text(
                        "$role\nRegistration",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0000f0)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: userTextController,
                    decoration: InputDecoration(
                        labelText: "Enter $role ID",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1.5),
                        )),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    obscureText: passwordVisibility,
                    controller: passTextController,
                    decoration: InputDecoration(
                        labelText: "Enter Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisibility = !passwordVisibility;
                            });
                          },
                          icon: passwordVisibility
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1.5),
                        )),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    obscureText: confirmPassVisibility,
                    controller: confirmPassTextController,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              confirmPassVisibility = !confirmPassVisibility;
                            });
                          },
                          icon: confirmPassVisibility
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1.5),
                        )),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (!loading) {
                        setState(() {
                          loading = true;
                        });
                        if (role.toLowerCase() == "faculty") {
                          await facultyReg();
                        } else {
                          await studentReg();
                        }
                        // If registration did not navigate away, disable loader.
                        if (mounted) {
                          setState(() {
                            loading = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(fontSize: 20, color: Color(0xff0000f0)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> facultyReg() async {
    final dbRef = FirebaseDatabase.instance.ref().child("Staff/faculty");
    await processRegistration(
        dbRef, "faculty", (String id) => FacultyMain(id));
  }

  Future<void> studentReg() async {
    final dbRef = FirebaseDatabase.instance.ref().child("Students");
    await processRegistration(
        dbRef, "student", (String id) => StudentDashboard(stud_id: id));
  }

  Future<void> processRegistration(DatabaseReference dbRef, String role,
      Widget Function(String) homePage) async {
    if (validateInput()) {
      try {
        final snapshot = await dbRef.get();
        bool exists = false;
        String email = "";
        String studentName = "";
        for (final sp in snapshot.children) {
          if (sp.key == userTextController.text) {
            exists = true;
            email = sp.child("email").value.toString();
            studentName = sp.child("name").value.toString();
            break;
          }
        }

        if (exists) {
          await _auth.createUserWithEmailAndPassword(
              email: email, password: passTextController.text);
          await sendEmail(email, userTextController.text,
              passTextController.text, role);
        } else {
          Fluttertoast.showToast(msg: "Invalid User ID");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> sendEmail(
      String email, String userName, String pass, String role) async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  email_verification(email, userName, pass, role)));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  bool validateInput() {
    if (userTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter an ID");
      return false;
    }
    if (passTextController.text.isEmpty ||
        passTextController.text.length < 6) {
      Fluttertoast.showToast(
          msg: "Password must be at least 6 characters long");
      return false;
    }
    if (confirmPassTextController.text != passTextController.text) {
      Fluttertoast.showToast(msg: "Passwords do not match");
      return false;
    }
    return true;
  }
}
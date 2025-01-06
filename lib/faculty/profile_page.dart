import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    // Check if the user is signed in
    if (_auth.currentUser == null) {
      // Redirect to the login screen if no user is signed in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });

      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If a user is signed in, fetch their profile data
    return Scaffold(
      body: FutureBuilder<DataSnapshot>(
        future: _database.ref('Faculties/${_auth.currentUser!.uid}').get(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle errors from Firebase
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching profile: ${snapshot.error}'));
          }

          // Handle the case where no data is found
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Icon(Icons.person, size: 100));
          }

          try {
            // Retrieve the faculty data safely
            var facultyData = snapshot.data!.value as Map<dynamic, dynamic>?;
            print("Faculty Data: $facultyData");

            if (facultyData == null) {
              return Center(child: Text('Faculty data not available.'));
            }

            // Use null-aware operators to safely access fields and provide default values
            String name = facultyData['name'] ?? 'Name not available';
            String facultyId = facultyData['faculty_id'] ?? 'N/A';
            String department = facultyData['department'] ?? 'N/A';
            String post = facultyData['post'] ?? 'N/A';
            String qualification = facultyData['qualification'] ?? 'N/A';
            String imgBase64 = facultyData['img'] ?? '';

            print("Base64 Image: $imgBase64");

            // Decode the image from Base64 if available
            ImageProvider profileImage;
            try {
              profileImage = imgBase64.isNotEmpty
                  ? MemoryImage(base64Decode(imgBase64))
                  : AssetImage('assets/default_profile.png');
            } catch (e) {
              print("Error decoding Base64 image: $e");
              profileImage = AssetImage('assets/default_profile.png');
            }

            // Now, we return the UI with safe handling for missing fields
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Circle at the top 25% area
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: profileImage,
                      child: imgBase64.isEmpty ? Icon(Icons.person, size: 80) : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Faculty Info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $name', style: TextStyle(fontSize: 18)),
                        Text('Faculty ID: $facultyId', style: TextStyle(fontSize: 18)),
                        Text('Department: $department', style: TextStyle(fontSize: 18)),
                        Text('Post: $post', style: TextStyle(fontSize: 18)),
                        Text('Qualification: $qualification', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  // Logout Button
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Logout', style: TextStyle(fontSize: 16)),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                      backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            print("Error occurred: $e");
            return Center(child: Text('An error occurred while fetching the profile.'));
          }
        },
      ),
    );
  }
}

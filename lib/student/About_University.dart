import 'package:NCSC/student/WebView_Page.dart';
import 'package:flutter/material.dart';

class About_Univercity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About University'),
        backgroundColor: Colors.orangeAccent.shade200,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset('assets/images/vnsgu_logo.png'),
              ),
              Center(
                child: Text(
                  'Veer Narmad South Gujarat University',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                          content:
                              'The motto is “सत्यम् ज्ञानम् अनन्तम्”, which means “Truth, '
                              'Knowledge, Infinity”. The three-part emblem illustrates '
                              'this with the Sun representing truth, the star representing '
                              'knowledge, and the spiral representing infinity.'),
                      _buildInfoCard(
                        title: 'History',
                        content:
                            'Established in 1965 and recognized by the University Grants Commission in 1968, '
                            'the university was renamed as Veer Narmad South Gujarat University in 2004 after the '
                            'renowned Gujarati poet Narmad.',
                      ),
                      _buildInfoCard(
                        title: 'Campus',
                        content:
                            'Located in Surat, Gujarat, the university spans over 210 acres, '
                            'offering modern facilities including a central library with over 1.72 lakh books, '
                            'sports amenities, and student hostels.',
                      ),
                      _buildInfoCard(
                        title: 'Academic Excellence',
                        content:
                            'VNSGU offers a wide range of undergraduate and postgraduate programs across various faculties such as Arts, Science, Commerce, Management, and Engineering. '
                            'The university has been re-accredited with a ‘B++’ grade by the National Accreditation and Assessment Council in 2022.',
                      ),
                      _buildInfoCard(
                          title: 'Notable Achievements',
                          content:
                              'The university has published over 2,000 scientific papers, contributing significantly to fields '
                              'like Chemistry, Biology, and Engineering. It ranks among the top universities in India for research output.'),
                      _buildInfoCard(
                        title: 'Affiliated Colleges',
                        content:
                            'VNSGU has a vast network of affiliated institutions, including 34 Government, '
                            '60 Grant-in-aid, and 285 Self-financed Colleges, along with 100 Post-graduate Teaching Centres.',
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebView_Page(
                          title: "Student Portal",
                          url: "https://vnsgu.net"
                      ),
                    ),
                  );
                },
                child: Text("Student Portal"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({String? title, required String content}) {
    return Card(
      color: Colors.orange.shade50,
      shadowColor: Colors.orangeAccent.shade200,
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title != null
                ? Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  )
                : Container(),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

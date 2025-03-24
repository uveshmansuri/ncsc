import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class About_Collage extends StatefulWidget {
  @override
  State<About_Collage> createState() => _About_CollageState();
}

class _About_CollageState extends State<About_Collage> {
  bool isScrolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About College"),
        backgroundColor: Colors.teal.shade200,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels > 50 && !isScrolled) {
            setState(() {
              isScrolled = true;
            });
          } else if (scrollNotification.metrics.pixels <= 50 && isScrolled) {
            setState(() {
              isScrolled = false;
            });
          }
          return true;
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade100, Colors.teal.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isScrolled
                      ?
                  Hero(
                        tag:"coll",
                        child: Row(
                            key: ValueKey("RowView"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                child: Image.asset("assets/images/logo1.png"),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Narmada College of Science and Commerce',
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),

                                    Text(
                                      'Established in 1985',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      )
                      :
                  Hero(
                        tag:"coll",
                        child: Column(
                            key: ValueKey("ColumnView"),
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset("assets/images/logo1.png"),
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'Narmada College of Science and Commerce',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Established in 1985',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // _buildPrincipalMessageCard(
                        //     name:
                        //     "Nilay MC",
                        //     //"Dr. A.K Sing",
                        //     msg:
                        //     "Do not Study to hard Fall for rich Girls Money Will come from their fathers Bank Account!!!",
                        //     // 'Welcome to Narmada College of Science and Commerce. '
                        //     // 'Our institution is committed to providing quality education and fostering an environment of '
                        //     // 'academic excellence. We believe in holistic development and strive to equip our students with the '
                        //     // 'skills and knowledge necessary to excel in their respective fields.',
                        //     img: "assets/images/imgNCSC1010001.png"
                        // ),

                        _buildInfoCard(
                          title: 'Overview',
                          content:
                          'Narmada College of Science and Commerce (NCSC), located in Zadeshwar, '
                              'Bharuch, is renowned for imparting quality education in English medium. '
                              'Affiliated with Veer Narmad South Gujarat University, the college offers various undergraduate and '
                              'postgraduate programs in science and commerce streams.',
                        ),

                        _buildInfoCard(
                          title: 'Academic Programs',
                          content:
                          'NCSC provides a range of courses, including B.Sc. in Chemistry, Computer Science, '
                              'and Electronics; B.Com.; BCA; BBA; M.Sc. in Chemistry; '
                              'and M.Com. in Financial Accounting and Marketing. These programs are designed to equip students '
                              'with both theoretical knowledge and practical skills.',
                        ),

                        _buildInfoCard(
                          title: 'Campus and Facilities',
                          content:
                          'The college campus is equipped with modern facilities, including well-equipped laboratories, '
                              'a comprehensive library, and amenities that support both academic and extracurricular activities, '
                              'fostering a holistic learning environment.',
                        ),

                        _buildInfoCard(
                          title: 'Best Practices',
                          content:
                          'NCSC emphasizes the use of Information and Communication Technology (ICT) in '
                              'teaching, learning, and evaluation processes. The institution also promotes '
                              'cashless transactions, aligning with the Digital India initiative, and has conducted awareness '
                              'programs to educate stakeholders about digital payment methods.',
                        ),

                        _buildInfoCard(
                          title: 'Rules of Conduct',
                          content:
                          'The college maintains a strict code of conduct to ensure a disciplined environment. '
                              'Students are expected to attend classes regularly, adhere to safety protocols in laboratories, '
                              'and uphold the institution’s standards both on and off-campus.',
                        ),

                        _buildInfoCard(
                          title: 'Collaborations',
                          content:
                          'NCSC has established Memorandums of Understanding (MoUs) with institutions like the Government '
                              'Engineering College, Bharuch, to enhance academic and research collaborations, providing students with '
                              'broader learning opportunities.',
                        ),

                        build_contect_us(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrincipalMessageCard({required var name, required var msg, required var img}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 10,
      color: Colors.teal.shade50,
      shadowColor: Colors.tealAccent.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.transparent, // Optional: Background color
                child: ClipOval(
                  child: Image.asset(
                    img,
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(
              'Message from the Principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              name,
              //"Dr. A.K Sing",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({var title, required String content}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 10,
      color: Colors.teal.shade50,
      shadowColor: Colors.tealAccent.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
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

  Widget build_contect_us(){
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 10,
      color: Colors.teal.shade50,
      shadowColor: Colors.tealAccent.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Icon(Icons.phone,),
                SizedBox(width: 5,),
                Text("+91 63543 99352")
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 5,),
                Text("principal@narmadacollege.ac.in")
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 5,),
                Text("Location")
              ],
            ),
            Location_tile()
          ],
        ),
      ),
    );
  }

  Widget Location_tile(){
    final double latitude = 21.726806;
    final double longitude = 73.0429887;
    // final double latitude = 21.1535603;
    // final double longitude = 72.7832581;
    return Container(
      height: 400,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15.5,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
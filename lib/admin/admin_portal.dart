import 'package:NCSC/admin/faculties.dart';
import 'package:NCSC/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class admin_portal extends StatefulWidget{
  @override
  State<admin_portal> createState() => _admin_portalState();
}

class _admin_portalState extends State<admin_portal> {
  @override
  Widget build(BuildContext context) {
    // double sc_width=MediaQuery.of(context).size.width;
    // double sc_height=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child:Text(
                    'Admin Portal',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          children:[
            UserAccountsDrawerHeader(
              accountName: Text('Wellcome,',style: TextStyle(fontSize: 20),),
              accountEmail: Text('admin101'),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_circle,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              trailing: Icon(Icons.output),
              title: Text('LOGOUT'),
              onTap:()=>show_dialouge(context),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, 0), // Center of the gradient
            radius: 1.0, // Spread of the gradient
            colors: [
              //Color(0xFFB2EBF2), // Slightly darker blue (edges)
              Color(0xffffffff),
              Color(0xFFE0F7FA), // Light blue (center)
            ],
            stops: [0.3, 1.0], // Defines the stops for the gradient
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 5.0),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       Builder(
                    //         builder: (context) => GestureDetector(
                    //           onTap: () => Scaffold.of(context).openDrawer(),
                    //           child: Container(
                    //             width: 50,
                    //             height: 50,
                    //             decoration: BoxDecoration(
                    //               color: Colors.blue.shade200,
                    //               shape: BoxShape.circle,
                    //             ),
                    //             child: Icon(
                    //               Icons.account_circle,
                    //               size: 50,
                    //               color: Colors.white,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 15),
                    //       Text(
                    //         'Admin Portal',
                    //         style: TextStyle(
                    //           fontSize: 30,
                    //           color: Colors.blue,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const Divider(color: Colors.black, thickness: 1),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/collageimg.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Hero(
                          tag: "dept",
                          child: _buildActionCard(
                            label: 'Departments',
                            icon: Icons.business,
                            onPressed: (){}
                            // onPressed: () => Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => DepartmentPage()),
                            // ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Hero(
                          tag: "faculty",
                          child: _buildActionCard(
                            label: 'Faculties',
                            icon: Icons.account_circle_rounded,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FacultyPage()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActionCard(
                          label: 'Subjects',
                          icon: Icons.book,
                          onPressed: (){}
                          // onPressed: () => Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => CreateSubjectPage()),
                          // ),
                        ),
                        _buildActionCard(
                            label: 'Circulars (Updates)',
                            icon: Icons.notifications,
                            onPressed: (){}
                          // onPressed: () => Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => CreateCircularPage()),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: BottomAppBar(
          color: Colors.blue,
          child: Text('© NARMADA COLLEGE SCIENCE AND COMMERCE',textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: 12),),
        ),
      )
    );
  }

  Widget _buildActionCard({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: Icon(icon, color: Colors.blue, size: 35),
        title: Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onTap: onPressed, // Make the entire ListTile tappable
      ),
    );
  }

  // void log_out() async{
  //   final pr=await SharedPreferences.getInstance();
  //   //show_dialouge(context);
  //   pr.clear();
  //   pr.setBool("login_flag", false);
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>login()));
  // }

  void show_dialouge(BuildContext context){
    showDialog(context: context,
        builder: (BuildContext context)=>
            AlertDialog(
              icon: Image.asset('assets/images/logo1.png',width: 80,height: 80,),
              title: Text("Confirm Logout"),
              content: Text("Are you sure you want to logout?"),
              actions: [
                TextButton(onPressed:
                    () {
                  Navigator.of(context).pop();
                    },
                    child: Text("Cancel")
                ),
                TextButton(onPressed: (){},
                    child: Text("Logout"),
                ),
              ],
            ),
    );
  }

  // void show_dialouge(BuildContext context){
  //   showDialog(context: context,builder: (BuildContext context)=>
  //       AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         icon: Image.asset('assets/images/logo1.png',width: 80,height: 80,),
  //         content: Container(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 children: [
  //                   Icon(Icons.logout,size: 40,color: Colors.lightBlue,),
  //                   SizedBox(width: 20,),
  //                   Text("NCSC",style:
  //                     TextStyle(fontSize: 30,color: Colors.lightBlue),
  //                   ),
  //                 ],
  //               ),
  //               Text("Are you sure to Logout?"),
  //               SizedBox(height: 30,),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   SizedBox(width: 70,),
  //                   ElevatedButton(onPressed: (){},
  //                       child:Text("No")),
  //                   ElevatedButton(onPressed: (){},
  //                       child:Text("Yes")),
  //                 ],
  //               )
  //             ],
  //           ),
  //         ),
  //       )
  //   );
  // }
}
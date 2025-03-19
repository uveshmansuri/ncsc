import 'package:flutter/material.dart';

import 'WebView_Page.dart';

class Fees_Portal extends StatefulWidget {
  @override
  State<Fees_Portal> createState() => _Fees_PortalState();
}

class _Fees_PortalState extends State<Fees_Portal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView_Page(title:"Fees Portal",url:'https://portal.narmadacollege.ac.in/'),
    );
  }
}


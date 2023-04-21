import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/widgets/large_screen.dart';
import 'package:hospital_system/widgets/medium_screen.dart';
import 'package:hospital_system/widgets/side_menu.dart';
import 'package:hospital_system/widgets/small_screen.dart';
import 'package:hospital_system/widgets/top_nav.dart';

class Sitelayout extends StatefulWidget {
  @override
  State<Sitelayout> createState() => _SitelayoutState();
}

class _SitelayoutState extends State<Sitelayout> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String name= "";
  String pic_url= "";

  @override
  void initState() {
    super.initState();
    getPatient();
  }

  Future<void> getPatient() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(currentUser!.uid)
        .get();
    final String currentUserName = currentUserDoc.data()!['Name'];
    final String pic = currentUserDoc.data()!['Pic_url'];

    setState(() {
      // Update the state with the fetched string value
      name = currentUserName.toString();
      pic_url = pic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: topNavigationBar(context, scaffoldKey, name, pic_url),
      drawer: Drawer(child: SideMenu()),
      body: ResponsiveWidget(largeScreen: LargeScreen(), smallScreen: SmallScreen(), mediumScreen: MediumScreen(),),
    );
  }
}

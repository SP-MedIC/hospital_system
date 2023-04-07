import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/pages/overview/widgets/info_cards.dart';

class OverviewCardsMediumScreen extends StatefulWidget {

  @override
  State<OverviewCardsMediumScreen> createState() => _OverViewCardsLargeScreenState();
}

class _OverViewCardsLargeScreenState extends State<OverviewCardsMediumScreen> {

  late final Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    _userStream = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(currentUser.uid)
        .snapshots();
  }

  //final User? user = FirebaseAuth.instance.currentUser;
  //final String userId = FirebaseAuth.instance.currentUser!.uid;
  //final Stream<DocumentSnapshot> userStream = FirebaseFirestore.instance
  //    .collection('hospitals')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //    .snapshots();

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return StreamBuilder(
      stream: _userStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        else if(snapshot.connectionState == ConnectionState.waiting){
          return const CircularProgressIndicator();
        }

        else if (!snapshot.hasData) {
          return const Center(child: Text('Data Unavailable'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final services = userData['services'] as Map<String, dynamic>;
        //final servicesList = services.values.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(left: 100),
                child: Row(
                  children: [
                    buildCard("Ambulance", services['ambulance'].toString(), Colors.orange ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("Emergency Room", services['emergency_room'].toString(), Colors.redAccent ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("General Ward", services['general_ward'].toString(), Colors.lightBlueAccent ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("Private Rooms", services['private_ward'].toString(), Colors.greenAccent ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("Maternal Ward", services['maternal_ward'].toString(), Colors.yellow ),
                    SizedBox(
                      width: _width/64,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Card buildCard(name, service,color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    color: light,
                  )
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                  service,
                  style: TextStyle(
                      fontSize: 40,
                      color: darke
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

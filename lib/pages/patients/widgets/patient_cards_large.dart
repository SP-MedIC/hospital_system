import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';

class OverViewCardsLargeScreen extends StatefulWidget {

  @override
  State<OverViewCardsLargeScreen> createState() => _OverViewCardsLargeScreenState();
}

class _OverViewCardsLargeScreenState extends State<OverViewCardsLargeScreen> {

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
        final services = userData['use_services'] as Map<String, dynamic>;
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
                      buildCard("General Ward", services['General Ward']['availability'].toString(), Colors.lightBlueAccent.shade100 ),
                      SizedBox(
                        width: _width/64,
                      ),
                      buildCard("Private Room", services['Private Room']['availability'].toString(), Colors.lightBlueAccent.shade100 ),
                      SizedBox(
                        width: _width/64,
                      ),
                      buildCard("Operating Room", services['Operating Room']['availability'].toString(), Colors.lightBlueAccent.shade100 ),
                      SizedBox(
                        width: _width/64,
                      ),
                      buildCard("Delivery Room", services['Labor Room']['availability'].toString(), Colors.lightBlueAccent.shade100),
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
                height: 5,
              ),
              Text(
                  service == '0' ? "-" : service,
                  style: TextStyle(
                      fontSize: 30,
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

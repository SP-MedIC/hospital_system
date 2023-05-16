import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';


class OverviewCardsMediumScreen extends StatefulWidget {

  @override
  State<OverviewCardsMediumScreen> createState() => _OverViewCardsLargeScreenState();
}

class _OverViewCardsLargeScreenState extends State<OverviewCardsMediumScreen> {

  late final Stream<DocumentSnapshot> _userStream;
  int totalNumParamedics =0;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    _userStream = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(currentUser.uid)
        .snapshots();
    Stream<int> totalParamedicsStream = ambulance();
    totalParamedicsStream.listen((int totalDocuments) {
      setState(() {
        totalNumParamedics = totalDocuments;
      });
    });
  }

  Stream<int> ambulance() {
    CollectionReference paramedics = FirebaseFirestore.instance.collection('users');

    Query availableParamedics = paramedics
        .where('Role', isEqualTo: 'Paramedic')
        .where('availability', isEqualTo: 'Online')
        .where('status', isEqualTo: 'Unassigned');
    // Listen for changes in the QuerySnapshot
    Stream<QuerySnapshot> querySnapshotStream = availableParamedics.snapshots();

    // Map the QuerySnapshot stream to an integer stream of the total number of documents
    Stream<int> totalNumParamedics = querySnapshotStream.map((QuerySnapshot querySnapshot) => querySnapshot.size);

    print(totalNumParamedics);
    // Return the stream of the updated total number of documents
    return totalNumParamedics;
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
                    buildCard("Ambulance", totalNumParamedics.toString(), Colors.redAccent ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("Emergency Room", services['Emergency Room']['availability'].toString(), Colors.orangeAccent ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("Labor Room", services['Labor Room']['availability'].toString(), Colors.lightBlueAccent ),
                    SizedBox(
                      width: _width/64,
                    ),
                    buildCard("Operating Room", services['Operating Room']['availability'].toString(), Colors.yellow ),
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
      color: Colors.white,
      child: ClipPath(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 10),
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      color: lightGrey,
                    )
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                    service == '0' ? "-" : service,
                    style: TextStyle(
                        fontSize: 40,
                        color: darke
                    )
                ),
              ],
            ),
          ),
        ),
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3)
            )
        ),
      ),
    );
  }
}

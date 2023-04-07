import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  String timeText = "";
  String dateText = "";

  late final CollectionReference<Map<String, dynamic>> collectionReference;
  late final Query<Map<String, dynamic>> query;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  String formatCurrentLiveTime(DateTime time){
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date){
    return DateFormat("dd MMMM, yyyy").format(date);
  }

  getCurrentLiveTime(){
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if(this.mounted){
      setState(() {
        timeText= liveTime;
        dateText= liveDate;
      });
    }
  }

  @override
  void initState(){
    super.initState();

    timeText= formatCurrentLiveTime(DateTime.now());

    dateText= formatCurrentDate(DateTime.now());

    Timer.periodic(const Duration(seconds: 1),(timer){
      getCurrentLiveTime();
    });

    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;
    collectionReference =
        FirebaseFirestore.instance.collection('hospitals');
    query = collectionReference.where('userId', isEqualTo: userId);
    stream = query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white70,
        body: Center(
          child: Column(
              children:[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 50,
                            color:Colors.black,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height:10),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 30,
                            color:Colors.black,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  child: Text(
                    "Hospital Services",
                    style: const TextStyle(
                      fontSize: 30,
                      color:Colors.red,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            final List<DocumentSnapshot<Map<String, dynamic>>> documents =
                                snapshot.data!.docs;
                            return DataTable(
                              columns: [
                                DataColumn(label: Text('Services')),
                                DataColumn(label: Text('Total')),
                              ],
                              rows: documents
                                  .map((document) => DataRow(
                                cells: document['Services'] != null
                                    ? [
                                  for (final entry in document['Services'].entries)
                                    DataCell(Text(entry.key)),
                                  for (final entry in document['Services'].entries)
                                    DataCell(Text(entry.value.toString())),
                                ]
                                    : [DataCell(Text('No data found')), DataCell(Text(''))],
                              ))
                                  .toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ]
          ),
        )
    );
  }
}

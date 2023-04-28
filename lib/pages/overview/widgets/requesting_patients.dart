import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hospital_system/pages/overview/widgets/auto_get_ambulance.dart';
import 'package:hospital_system/pages/overview/widgets/view_patient_info.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/pages/overview/widgets/request_patient_info.dart';
import 'package:hospital_system/widgets/custom_text.dart';

class RequestingPatients extends StatefulWidget {
  @override
  State<RequestingPatients> createState() => _RequestingPatientsState();
}

class _RequestingPatientsState extends State<RequestingPatients> {

  final CollectionReference patients =
  FirebaseFirestore.instance.collection('hospitals_patients');

  String myString= "";
  String userId = FirebaseAuth.instance.currentUser!.uid;
  final List<DataRow> rows = [];

  String userAddress = "";
  String nearestAmbulance = "";
  String currentLat = "";
  String currentLng = "";
  String travel_mode = "";
  String triageResult = "";
  String name = "";
  String age = "";
  String sex = "";
  String birthday = "";
  String address = "";
  String concerns = "";
  String status = "";

  Map<String, dynamic> ambulanceMap = {};
  List<String> listSymptoms = [];


  @override
  void initState() {
    super.initState();
    getPatient();
    updateTriageResult();
  }

  // Function to update "triage result" field based on different cases
  void updateTriageResult() async {
    // Get reference to the "hospitals_patients" collection
    CollectionReference patientsCollection =
    FirebaseFirestore.instance.collection('hospitals_patients');

    // Update "triage result" field to 1 for "emergency case" patients
    QuerySnapshot emergencyQuerySnapshot =
    await patientsCollection.where('triage_result', isEqualTo: 'Emergency Case').get();
    emergencyQuerySnapshot.docs.forEach((DocumentSnapshot doc) async {
      await patientsCollection.doc(doc.id).update({'triage_result': 'A'});
    });

    // Update "triage result" field to 2 for "priority case" patients
    QuerySnapshot priorityQuerySnapshot =
    await patientsCollection.where('triage_result', isEqualTo: 'Priority Case').get();
    priorityQuerySnapshot.docs.forEach((DocumentSnapshot doc) async {
      await patientsCollection.doc(doc.id).update({'triage_result': 'B'});
    });

    // Update "triage result" field to 3 for "non-urgent case" patients
    QuerySnapshot nonUrgentQuerySnapshot =
    await patientsCollection.where('triage_result', isEqualTo: 'Non-urgent Case').get();
    nonUrgentQuerySnapshot.docs.forEach((DocumentSnapshot doc) async {
      await patientsCollection.doc(doc.id).update({'triage_result': 'C'});
    });
  }

  Future<void> getPatient() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final currentUserDoc = await FirebaseFirestore.instance
      .collection('hospitals')
      .doc(currentUser!.uid)
      .get();
  final String currentUserName = currentUserDoc.data()!['Name'];

  setState(() {
    // Update the state with the fetched string value
    myString = currentUserName.toString();
  });
  }


  Future<void> createDocument(String? paramedic) async {
    //final patientDoc = await FirebaseFirestore.instance.collection('hospitals_patients').doc(docId).get();
    //FirebaseFirestore.instance.collection('hospitals').doc(userId).collection('patient').add(patientDoc as Map<String, dynamic>);
    FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'use_services.Emergency Room.availability': FieldValue.increment(-1),
    });



    FirebaseFirestore.instance.collection('hospitals').doc(userId).collection('patient').add({
      'Name:': name,
      'Birthday': birthday,
      'Sex': sex,
      'Main Concerns': concerns,
      'Symptoms': listSymptoms,
      'Triage Result': triageResult,
      'Travel Mode': travel_mode,
      'Age': age,
      'Address': address,
      'in_charge': paramedic,
      'Service in use': "Emergency Room",
      'Status': status,
      'Location' : {
        'Latitude' : currentLat.toString(),
        'Longitude': currentLng.toString(),
      },
      'accepted_at': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: patients.where('hospital_user_id', isEqualTo: myString).where('status', isNotEqualTo: 'accepted').orderBy("triage_result").limit(3).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print(myString);
          return CircularProgressIndicator();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn2(label: Text('Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Age',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Gender',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Birthday',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Triage Result',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                  ],
                  rows: snapshot.data!.docs.map((doc) {
                    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    triageResult = data['triage_result'].toString();
                    name = data['Name:'].toString();
                    age = data['Age'].toString();
                    sex = data['Sex'].toString();
                    birthday = data['Birthday'].toString();
                    address = data['Address'].toString();
                    concerns = data['Main Concerns'].toString();
                    travel_mode = data['Travel Mode'].toString();
                    status = data['Status'].toString();
                    listSymptoms = List<String>.from(data['Symptoms']);
                    print(listSymptoms);

                    // Return the corresponding string based on the value of "Triage Result"
                    if (triageResult == 'A') {
                      triageResult = 'Emergency Case';
                      print(triageResult.runtimeType);
                    } else if (triageResult == 'B') {
                      triageResult = 'Priority Case';
                    } else if (triageResult == 'C'){
                      triageResult = 'Non-urgent Case';
                    }

                    // create view button widget
                    final viewButton = ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Patient Information"),
                              content: SingleChildScrollView(
                                //width: double.maxFinite,
                                //scrollDirection: Axis.vertical,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(child: Text('Name: $name')),
                                    SizedBox(height: 5,),
                                    Text('Age: $age'),
                                    SizedBox(height: 5,),
                                    Text('Sex: $sex'),
                                    SizedBox(height: 5,),
                                    Text('Birthday: $birthday'),
                                    SizedBox(height: 5,),
                                    Text('Address: $address'),
                                    SizedBox(height: 5,),
                                    Text('Main Concerns: $concerns'),
                                    SizedBox(height: 5,),
                                    Text('Symptoms'),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: listSymptoms != null
                                          ? listSymptoms.map((s) => Text('- $s')).toList()
                                          : [Text('No Symptoms added')],
                                    ),
                                    SizedBox(height: 5,),
                                    Text('Triage Result: $triageResult'),
                                    SizedBox(height: 5,),
                                    Text('Mode of travel: $travel_mode'),
                                    SizedBox(height: 5,),
                                    Text('Status: $status'),
                                    SizedBox(height: 16.0),
                                  ],
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  child: Text('Reject'),
                                  onPressed: () {
                                    final updatedDoc = {
                                      'Status': 'rejected',
                                    };
                                    FirebaseFirestore.instance
                                        .collection('hospitals_patients')
                                        .doc(doc.id)
                                        .update(updatedDoc)
                                        .then((value) {
                                      //Navigator.of(context).pop();
                                    }).catchError((error) {
                                      print('Error updating document: $error');
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Accept'),
                                  onPressed: () async {
                                    currentLat = data['Location']['Latitude'];
                                    currentLng = data['Location']['Longitude'];
                                    print(currentLat);
                                    //travel_mode = data['Travel Mode'].toString();

                                    if(travel_mode == 'AMBULANCE'){
                                      ambulanceMap = await AutoGetAmbulance(endLat: currentLat, endLng: currentLng).main();
                                      print("hospital list: $ambulanceMap");

                                      var nearest = ambulanceMap.values.cast<num>().reduce(min);
                                      ambulanceMap.forEach((key, value) {
                                        if (value == nearest) {
                                          nearestAmbulance = key;
                                        }
                                      });
                                      print(nearestAmbulance.runtimeType);

                                      createDocument(nearestAmbulance);
                                    }else if (travel_mode == 'PRIVATE VEHICLE'){
                                      nearestAmbulance = "None";
                                      createDocument(nearestAmbulance);
                                    }

                                    final updatedDoc = {
                                      'Status': 'accepted',
                                    };
                                    FirebaseFirestore.instance
                                        .collection('hospitals_patients')
                                        .doc(doc.id)
                                        .update(updatedDoc)
                                        .then((value) {
                                      //Navigator.of(context).pop();
                                    }).catchError((error) {
                                      print('Error updating document: $error');
                                    });

                                    // You can add your logic for accepting the document here
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )
                        );
                        //patientInfo.show(context, doc, triageResult);
                      },
                      child: Text('View', style: TextStyle(decoration: TextDecoration.underline,),),
                    );

                    return DataRow(cells: [
                      DataCell(Center(child: Text(data['Name:']))),
                      DataCell(Center(child: Text(data['Age'].toString()))),
                      DataCell(Center(child: Text(data['Sex']))),
                      DataCell(Center(child: Text(data['Birthday']))),
                      DataCell(Center(child: Text(triageResult))),
                      DataCell(Center(child: viewButton)),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

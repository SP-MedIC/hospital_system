import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hospital_system/pages/overview/widgets/auto_get_ambulance.dart';
import 'package:hospital_system/pages/patients/widgets/view_patient_info.dart';
import 'package:hospital_system/constants/style.dart';
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
  int numberOfRows = 5;

  String userAddress = "";
  String nearestAmbulance = "";
  String currentLat = "";
  String currentLng = "";
  String travel_mode = "";
  String triageResult = "";

  Map<String, dynamic> ambulanceMap = {};
  List<String> listSymptoms = [];

  late final Stream<QuerySnapshot> _patientStream;

  @override
  void initState() {
    super.initState();
    getPatient();
    updateTriageResult();
    //Query current = patients.where('hospital_user_id', isEqualTo: myString).orderBy("requested_time",descending: false).where('Status', isEqualTo: 'pending');
    //_patientStream = current.orderBy('triage_result',descending: true).snapshots();
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


  Future<void> createDocument(String? paramedic, String docId, String? triageResult) async {
    FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'use_services.Emergency Room.availability': FieldValue.increment(-1),
    });

    if(paramedic != "None"){
      FirebaseFirestore.instance
          .collection('users')
          .doc(paramedic)
          .update({
        'status': "Assigned",
        'assign_patient': docId,    });
    }

    final CollectionReference hospitalPatient =
    FirebaseFirestore.instance.collection('hospitals').doc(userId).collection('patient');

    final patient = await FirebaseFirestore.instance
        .collection('hospitals_patients')
        .doc(docId)
        .get();
    //final DocumentSnapshot documentSnapshot = await patients.doc(docId).get();

    // Check if the document exists
    if (patient.exists) {
      // Retrieve the data as a Map<String, dynamic>
      final Map<String, dynamic> data = patient.data() as Map<String, dynamic>;

      // Add the data to the destination collection
      final DocumentReference patientDoc = await hospitalPatient.add(data);

      //await hospitalPatient.add(data);
      await patientDoc.update({
        'paramedic_id': paramedic,
        'Service in use': "Ambulance",
        'triage_result': triageResult,
        'accepted_at': Timestamp.now(),
        'discharged_at':"",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: patients.where('hospital_user_id', isEqualTo: myString).orderBy("triage_result",).where('Status', isEqualTo: 'pending').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print(myString);
          return CircularProgressIndicator();
        }

        if (snapshot.data!.docs.length < numberOfRows) {
          numberOfRows = snapshot.data!.docs.length;
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn2(label: Text('Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Age',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Gender',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Birthday',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Phone Number',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Triage Result',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    final rowData = doc.data() as Map<String, dynamic>;

                    // Return the corresponding string based on the value of "Triage Result"
                    String triageResult = rowData['triage_result'].toString();
                    List<String> listSymptoms = List<String>.from(rowData['Symptoms']);

                    if (rowData['triage_result'] == 'A') {
                      triageResult = 'Emergency Case';
                      //print(triageResult);
                    } else if (rowData['triage_result'] == 'B') {
                      triageResult = 'Priority Case';
                    } else if (rowData['triage_result'] == 'C'){
                      triageResult = 'Non-urgent Case';
                    }

                    // create view button widget
                    final viewButton = viewPatientInfo(context, rowData, doc, triageResult, listSymptoms);

                    return DataRow(cells: [
                      DataCell(Center(child: Text(rowData['Name']))),
                      DataCell(Center(child: Text(rowData['Age'].toString()))),
                      DataCell(Center(child: Text(rowData['Sex']))),
                      DataCell(Center(child: Text(rowData['Birthday']))),
                      DataCell(Center(child: Text(rowData['Contact Number']))),
                      DataCell(Center(child: Text(triageResult))),
                      DataCell(Center(child: viewButton)),
                    ]);
                  }).toList().sublist(0, numberOfRows),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        numberOfRows = 5;
                      });
                    },
                    child: Text('5'),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        numberOfRows = 10;
                      });
                    },
                    child: Text('10'),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        numberOfRows = snapshot.data!.docs.length;
                      });
                    },
                    child: Text('All'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  ElevatedButton viewPatientInfo(BuildContext context, Map<String, dynamic> data, DocumentSnapshot<Object?> doc, String triageResult, List<String> listSymptoms) {
    return ElevatedButton(
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
                    Column(
                      children: [
                        Text('Name'),
                        Text(data['Name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      children: [
                        Text('Age'),
                        Text(data['Age'],style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      children: [
                        Text('Sex'),
                        Text(data['Sex'],style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      children: [
                        Text('Main Concerns'),
                        Text(data['Main Concerns'],style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Text('Symptoms'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: listSymptoms != null
                          ? listSymptoms.map((s) => Text('- $s',style: TextStyle(fontWeight: FontWeight.bold))).toList()
                          : [Text('No Symptoms added')],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      children: [
                        Text('Triage Result'),
                        Text(triageResult,style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      children: [
                        Text('Mode of Transportation'),
                        Text(data['Travel Mode'],style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      children: [
                        Text('Confirmation Status'),
                        Text(data['Status'],style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: light,
                    primary: Color(0xFFba181b),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    onPrimary: darke,
                    primary: Color(0xFFC2FFAD),
                  ),
                  child: Text('Accept'),
                  onPressed: () async {
                    currentLat = data['Location']['Latitude'];
                    currentLng = data['Location']['Longitude'];
                    print(currentLat);
                    //travel_mode = data['Travel Mode'].toString();
                    if(data['Travel Mode'] == 'AMBULANCE'){
                      ambulanceMap = await AutoGetAmbulance(endLat: currentLat, endLng: currentLng).main();
                      print("hospital list: $ambulanceMap");
                      var nearest = ambulanceMap.values.cast<num>().reduce(min);
                      ambulanceMap.forEach((key, value) {
                        if (value == nearest) {
                          nearestAmbulance = key;
                        }
                      });
                      print(nearestAmbulance.runtimeType);
                      createDocument(nearestAmbulance, doc.id, triageResult);
                    }else if (data['Travel Mode'] == 'Private Vehicle'){
                      nearestAmbulance = "None";
                      createDocument(nearestAmbulance, doc.id, triageResult);
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
  }
}
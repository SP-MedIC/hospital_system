import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hospital_system/pages/overview/widgets/auto_get_ambulance.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:intl/intl.dart';



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

  List<DocumentSnapshot> documents = [];

  int activeAmbulance =0;

  @override
  void initState() {
    super.initState();
    getPatient();
    updateTriageResult();
    //ambulance();
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

  //Get the hospital name patient requested to
  Future<void> getPatient() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final currentUserDoc = await FirebaseFirestore.instance
      .collection('hospitals')
      .doc(currentUser!.uid)
      .get();
  final String currentUserName = currentUserDoc.data()!['Name'];

  setState(() {
    // Update the state with the hospital name
    myString = currentUserName.toString();
  });
  }

  //Copy and Update the patient document
  Future<void> createDocument(String? paramedic, String docId, String? triageResult) async {

    FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'use_services.Emergency Room.availability': FieldValue.increment(-1),
    });

    final CollectionReference hospitalPatient =
    FirebaseFirestore.instance.collection('hospitals').doc(userId).collection('patient');

    //Get patient data
    final patient = await FirebaseFirestore.instance
        .collection('hospitals_patients')
        .doc(docId)
        .get();

    // Check if the patient document exists
    if (patient.exists) {
      // Retrieve, copy and add the patient data
      final Map<String, dynamic> data = patient.data() as Map<String, dynamic>;

      final DocumentReference patientDoc = hospitalPatient.doc(docId);

      await patientDoc.set(data);

      if(paramedic == "None"){
        //add additional information for patient in private vechile
        await patientDoc.update({
          'paramedic_id': paramedic,
          'Service in use': "None",
          'Status':"Incoming",
          'triage_result': triageResult,
          'accepted_at': Timestamp.now(),
          'discharged_at':"",
        });
      }else {
        //add additional information for patient in ambulance
        await patientDoc.update({
          'paramedic_id': paramedic,
          'Service in use': "Ambulance",
          'triage_result': triageResult,
          'accepted_at': Timestamp.now(),
          'discharged_at': "",
        });
      }
    }

    print(paramedic);
    if(paramedic != "None"){
      FirebaseFirestore.instance
          .collection('users')
          .doc(paramedic)
          .update({
        'status': "Assigned",
        'assigned_patient':{
          'assign_patient': docId,
          'hospital_id':userId.toString(),
        },
      });
    }
  }

  //Check the number of paramedic available
  Future<void> ambulance() async {
    print(activeAmbulance);
    CollectionReference paramedics = FirebaseFirestore.instance.collection('users');

    Query availableParamedics = paramedics
        .where('Role', isEqualTo: 'Paramedic')
        .where('availability', isEqualTo: 'Online')
        .where('status', isEqualTo: 'Unassigned');

    QuerySnapshot querySnapshot = await availableParamedics.get();
    int totalNumParamedics = querySnapshot.size;

    setState(() {
      activeAmbulance = totalNumParamedics;
    });

    print(activeAmbulance);
    // // Return the stream of the updated total number of documents
    // return totalNumParamedics;
  }

  @override
  Widget build(BuildContext context) {
    // Create the stream based on the query and data table filters
    Stream<QuerySnapshot> _patientStream;
    if (numberOfRows == 5 || numberOfRows == 10) {
      _patientStream = patients
          .where('hospital_user_id', isEqualTo: myString)
          .orderBy("triage_result", descending:false)
          .where('Status', isEqualTo: 'pending')
          .orderBy("requested_time", descending:false)
          .limit(numberOfRows)
          .snapshots();
    } else {
      _patientStream = patients
          .where('hospital_user_id', isEqualTo: myString)
          .orderBy("triage_result", descending:false)
          .where('Status', isEqualTo: 'pending')
          .orderBy("requested_time", descending:false)
          .snapshots();
    }
    //double _width = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream: _patientStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print(myString);
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.docs;
        if (data.isEmpty) {
          return Center(child: Text('No pending request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25), ));
        }
        //Data table
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 5,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Triage Result',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn2(label: Text('Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Age',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Phone Number',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    final rowData = doc.data() as Map<String, dynamic>;

                    // Return the corresponding string based on the value of "Triage Result"
                    String triageResult = rowData['triage_result'].toString();
                    List<String> listSymptoms = List<String>.from(rowData['Symptoms']);
                    Color? triageColor;

                    //adding label to triage results category
                    if (rowData['triage_result'] == 'A') {
                      triageResult = 'Emergency Case';
                      triageColor = Colors.red;
                    } else if (rowData['triage_result'] == 'B') {
                      triageResult = 'Priority Case';
                      triageColor = Colors.orange;
                    } else if (rowData['triage_result'] == 'C'){
                      triageResult = 'Non-urgent Case';
                      triageColor = Colors.green;
                    }


                    // create view button widget
                    final viewButton = viewPatientInfo(context, rowData, doc, triageResult, listSymptoms);

                    return DataRow(cells: [
                      DataCell(
                        Center(
                            child: Text(
                              triageResult,
                              style: TextStyle(
                                fontSize:15,
                                fontWeight: FontWeight.bold,
                                color: triageColor,
                              ),
                            )
                        ),
                      ),
                      DataCell(Center(child: Text(rowData['Name']))),
                      DataCell(Center(child: Text(rowData['Age'].toString()))),
                      DataCell(Center(child: Text(rowData['Contact Number']))),
                      DataCell(Center(child: viewButton)),
                    ]);
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              //Adding a filter buttons to set the number of rows
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

  //Widget for the view button
  ElevatedButton viewPatientInfo(BuildContext context, Map<String, dynamic> data, DocumentSnapshot<Object?> doc, String triageResult, List<String> listSymptoms) {
    Timestamp timestampRequested = data['requested_time'] as Timestamp;
    DateTime dateTimeRequested = timestampRequested.toDate();
    return ElevatedButton(
      onPressed: () {
        ambulance();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Center(child: Text("Patient Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text on the left
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Name: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: data['Name'], style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Age: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(text: data['Age'], style: TextStyle(fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Sex: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(text: data['Sex'], style: TextStyle(fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Main Concerns: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: data['Main Concerns'], style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Text('Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: listSymptoms != null
                          ? listSymptoms.map((s) => Text('- $s', style: TextStyle(fontWeight: FontWeight.normal))).toList()
                          : [Text('No Symptoms added'),],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Triage Result: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: triageResult, style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Mode of Transportation: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: data['Travel Mode'], style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Confirmation Status: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: data['Status'], style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Requested Time: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeRequested).toString(), style: TextStyle(fontWeight: FontWeight.normal)
                              ),
                            ],
                          ),
                        ),
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
                    // Stream<int> availableParamedics = ambulance();
                    if (activeAmbulance == 0 && data['Travel Mode'] == 'AMBULANCE') {
                      print('No Ambulance');
                      FirebaseFirestore.instance
                          .collection('hospitals_patients')
                          .doc(doc.id)
                          .update({'Status': 'No Ambulance'})
                          .then((value) {
                        //Navigator.of(context).pop();
                      }).catchError((error) {
                        print('Error updating document: $error');
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('hospitals_patients')
                          .doc(doc.id)
                          .update({'Status': 'rejected'})
                          .then((value) {
                        //Navigator.of(context).pop();
                      }).catchError((error) {
                        print('Error updating document: $error');
                      });
                    }
                    Navigator.of(context).pop();
                  }
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: darke,
                    primary: Color(0xFFC2FFAD),
                  ),
                  child: Text('Accept'),
                  onPressed: () async {
                    DocumentSnapshot userDoc = await FirebaseFirestore.instance
                        .collection('hospitals')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get();
                    var serviceData = userDoc.data() as Map<String, dynamic>;
                    var newservice = serviceData['use_services']['Emergency Room']['availability'];
                    print(newservice);

                    if (newservice != 0) {
                      //get the patient current latitude and longitude
                      currentLat = data['Location']['Latitude'].toString();
                      currentLng = data['Location']['Longitude'].toString();

                      //Checking the mode of travel
                      if (data['Travel Mode'] == 'AMBULANCE') {
                        //return list of available ambulances with their traffic time
                        ambulanceMap = await AutoGetAmbulance(
                            endLat: currentLat, endLng: currentLng).main();

                        //get the key with the minimum traffic time
                        var nearest = ambulanceMap.values.cast<num>().reduce(
                            min);
                        ambulanceMap.forEach((key, value) {
                          if (value == nearest) {
                            nearestAmbulance = key;
                          }
                        });
                        print(nearestAmbulance.runtimeType);
                        //call createDocument
                        createDocument(nearestAmbulance, doc.id, triageResult);
                      } else if (data['Travel Mode'] == 'Private Vehicle') {
                        //setting nearestAmbulance to None
                        nearestAmbulance = "None";
                        //call createDocument
                        createDocument(nearestAmbulance, doc.id, triageResult);
                      }
                      //change patient status to accepted
                      final updatedDoc = {
                        'Status': 'accepted',
                      };
                      //Update the current document
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
                    }
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

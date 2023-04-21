import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  //List<String> listSymptoms = [];


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

  Future<void> acceptPatients(String docId) async{
    QuerySnapshot paramedics = await FirebaseFirestore.instance
        .collection('Paramedic_Users')
        .where('availability', isEqualTo: 'Online')
        .where('status', isEqualTo: 'Unassigned')
        .get();

  }
  Future computeDistance({
    required String startLatitude,
    required String startLongitude,
    required String endLatitude,
    required String endLongitude,
    required String trafficModel,
    required String departureTime,
  }) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$endLatitude,$endLongitude&origins=$startLatitude,$startLongitude&traffic_model=$trafficModel&departure_time=$departureTime&key=AIzaSyAS8T5voHU_bam5GCQIELBbWirb9bCZZOA';
    //String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$destination&origins=$origin&&traffic_model=$trafficModel&departure_time=$departureTime&key=AIzaSyAS8T5voHU_bam5GCQIELBbWirb9bCZZOA';

    try {
      var response = await Dio().get(url);
      if (response.statusCode == 200) {
        //print(response.data);
        for (var row in response.data['rows']) {
          for (var element in row['elements']) {
            //print(element['duration_in_traffic']['value']);
            return (element['duration_in_traffic']['value']);
          }
        }
      }
      else {
        return;
      }
    }
    catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: patients.where('hospital_user_id', isEqualTo: myString).orderBy("triage_result").limit(3).snapshots(),
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
                    String triageResult = data['triage_result'].toString();
                    String name = data['Name:'].toString();
                    String age = data['Age'].toString();
                    String sex = data['Sex'].toString();
                    String birthday = data['Birthday'].toString();
                    String address = data['Address'].toString();
                    String concerns = data['Main Concerns'].toString();
                    String travel_mode = data['Travel Mode'].toString();
                    String status = data['Status'].toString();
                    final List<dynamic> symptoms = data['Symptoms'] as List<dynamic>;

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
                                scrollDirection: Axis.vertical,
                                child: Column(
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
                                    Text('Triage Result: $triageResult'),
                                    SizedBox(height: 5,),
                                    Text('Triage Result: $travel_mode'),
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
                                      Navigator.of(context).pop();
                                    }).catchError((error) {
                                      print('Error updating document: $error');
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Accept'),
                                  onPressed: () {
                                    final currentLat = data['Location']['Latitude'];
                                    final currentLng = data['Location']['Longitude'];

                                    final query = FirebaseFirestore.instance
                                        .collection('Paramedic_Users')
                                        .where('availability', isEqualTo: 'Online')
                                        .where('status', isEqualTo: 'Unassigned');

                                    // Sort the documents by distance from the current location
                                    query.get().then((QuerySnapshot snapshot) {
                                      // Initialize the shortest distance to a high number
                                      var shortdistance = double.infinity;
                                      String nearestPatient = '';

                                      snapshot.docs.forEach((DocumentSnapshot doc) {
                                        final Map<String, dynamic> paramedicData = doc.data() as Map<String, dynamic>;

                                        // Calculate the distance to the current location
                                        //final paramedicLat = paramedicData['Location']['Latitude'];
                                        //final paramedicLng = paramedicData['Location']['Longitude'];
                                        var distance = computeDistance(
                                          startLatitude: currentLat,
                                          startLongitude: currentLng,
                                          endLatitude: data['Location']['Latitude'],
                                          endLongitude: data['Location']['Longitude'],
                                          trafficModel: 'best_guess', //integrates live traffic information
                                          departureTime: 'now',
                                        );

                                        // Check if this is the nearest patient so far
                                        if (distance < shortdistance) {
                                          shortdistance = distance;
                                          nearestPatient = paramedicData['Name:'];
                                        }
                                      });

                                      // Accept the current patient and print the nearest patient's name
                                      print('Accepted patient: ${data['Name:']}');
                                      print('Nearest patient: $nearestPatient');
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

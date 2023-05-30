import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/pages/patients/widgets/patient_cards_large.dart';
import 'package:hospital_system/pages/patients/widgets/patient_cards_medium.dart';
import 'package:hospital_system/pages/patients/widgets/patient_cards_small.dart';
import 'package:hospital_system/widgets/custom_text.dart';

import '../../../helpers/responsiveness.dart';

class ViewPatientInformation extends StatefulWidget {
  @override
  _ViewPatientInformationState createState() => _ViewPatientInformationState();
}

class _ViewPatientInformationState extends State<ViewPatientInformation> {

  CollectionReference patients =
  FirebaseFirestore.instance.collection('hospitals').doc(FirebaseAuth.instance.currentUser!.uid).collection('patient');


  final List<DataRow> rows = [];
  String selectedType = '';
  //String prev = '';
  List<String> services = ['Ambulance'];
  List<String> user_services = [];
  String searchText = '';
  TextEditingController controller = TextEditingController();

  late final Stream<QuerySnapshot> _patientStream;

  @override
  void initState() {
    super.initState();
    getListService();

  }

  void getListService() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var service = userDoc['use_services'] as Map<String, dynamic>;
    var serviceNames = service.keys.toList();

    //Adding list of services to be displayed
    services.addAll(List<String>.from(serviceNames));
    services.add('None');

    //Adding list of services for checking
    user_services.addAll(List<String>.from(serviceNames));
  }

  Future<void> updateServiceInUse(String docId, String? newValue, String? prev) async {

    CollectionReference hospitalsRef = FirebaseFirestore.instance.collection('hospitals');

// assume we have a document with ID 'user1' in the 'users' collection
    DocumentReference hospitalRef = hospitalsRef.doc(FirebaseAuth.instance.currentUser!.uid);

    // update the service_in_use field in Firestore
    hospitalRef.collection('patient')
        .doc(docId)
        .update({'Service in use': newValue})
        .then((value) {
      print('Service in use updated');

      if (newValue == 'None'){
        hospitalRef.collection('patient').doc(docId).update({
          'Status':'discharged',
          'discharged_at':Timestamp.now(),
        });
      }else if(newValue == 'Emergency Room'){
        hospitalRef.collection('patient').doc(docId).update({
          'Status':'In-patient',
          'discharged_at':Timestamp.now(),
        });
      }

      // decrement/increment the respective fields under the services map field
      if (prev != null && prev != newValue) {
        if (user_services.contains(prev)) {
          // decrement the field with the same name as previousValue
          hospitalRef.update({'use_services.$prev.availability': FieldValue.increment(1)});
        }
        if (user_services.contains(newValue) && newValue != "Emergency Room") {
          // increment the field with the same name as newValue
          hospitalRef.update({'use_services.$newValue.availability': FieldValue.increment(-1)});
        }
      }
    }).catchError((error) => print('Failed to update service in use: $error'));
  }


  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot> (
      stream:FirebaseFirestore.instance.collection('hospitals')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('patient')
          .where('Status', isNotEqualTo: 'discharged')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      }),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                        searchText = '';
                      });
                    },
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn2(label: Text('Status', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Name',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Age',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Gender',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Birthday',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Phone Number',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Service in Use',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                  ],
                  rows: snapshot.data!.docs.where((doc) => searchText.isEmpty ||
                      doc['Name'].toString().toLowerCase().contains(searchText.toLowerCase()))//||
                      //doc['Status'].toString().toLowerCase().contains(searchText.toLowerCase()))
                      .map((DocumentSnapshot doc) {
                    final rowData = doc.data() as Map<String, dynamic>;
                    String prev = rowData['Service in use'];
                    List<String> listSymptoms = List<String>.from(rowData['Symptoms']);

                    // create view button widget
                    final viewButton = viewPatientInfo(context, rowData, doc, listSymptoms);
                    final serviceInUse = TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.lightBlue.withOpacity(0.5);
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.lightBlue.withOpacity(0.5);
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        serviceUse(context, doc, prev);
                      },
                      child: Text(rowData['Service in use'], style: TextStyle(fontWeight: FontWeight.w500, decoration: TextDecoration.underline,),),
                    );

                    return DataRow(cells: [
                      DataCell(Center(child: Text(rowData['Status']))),
                      DataCell(Center(child: Text(rowData['Name']))),
                      DataCell(Center(child: Text(rowData['Age'].toString()))),
                      DataCell(Center(child: Text(rowData['Sex']))),
                      DataCell(Center(child: Text(rowData['Birthday']))),
                      DataCell(Center(child: Text(rowData['Contact Number'].toString()))),
                      DataCell(Center(child: serviceInUse)),
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

  //Select Service patient currently using
  Future<dynamic> serviceUse(BuildContext context, DocumentSnapshot<Object?> doc, String prev) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: services.map((String option) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: Text(option),
                    onPressed: () async {
                      print(option.runtimeType);
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance
                          .collection('hospitals')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      var serviceData = userDoc.data() as Map<String, dynamic>;
                      var newservice = serviceData['use_services'][option]['availability'];
                      print(newservice);

                      if (newservice != 0) {
                        updateServiceInUse(doc.id, option, prev);
                        Navigator.of(context).pop();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Service Unavailable'),
                              content: Text('The selected service is currently unavailable.'),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: light,
                                    primary: Colors.redAccent,
                                  ),
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: light,
                  primary: Colors.redAccent,
                ),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  //View complete Patient Information
  ElevatedButton viewPatientInfo(BuildContext context, Map<String, dynamic> data, DocumentSnapshot<Object?> doc, List<String> listSymptoms) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
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
                            Text(data['Name'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Age'),
                            Text(data['Age'].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Sex'),
                            Text(data['Sex'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Contact Information'),
                            Text(data['Contact Number'].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Address'),
                            Text(data['Address'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Main Concerns'),
                            Text(data['Main Concerns'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text('Symptoms'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listSymptoms != null
                              ? listSymptoms.map((s) =>
                              Text('- $s', style: TextStyle(
                                  fontWeight: FontWeight.bold)))
                              .toList()
                              : [Text('No Symptoms added')],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Triage Result'),
                            Text(data['triage_result'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Confirmation Status'),
                            Text(data['Status'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Column(
                          children: [
                            Text('Mode of Travel'),
                            Text(data['Travel Mode'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          onPrimary: Colors.white,
                          primary: active,
                        ),
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
        );
        //patientInfo.show(context, doc, triageResult);
      },
      child: Text(
        'View', style: TextStyle(decoration: TextDecoration.underline,),),
    );
  }
}
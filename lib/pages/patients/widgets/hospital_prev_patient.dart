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

class PreviousPatient extends StatefulWidget {
  @override
  _PreviousPatient createState() => _PreviousPatient();
}

class _PreviousPatient extends State<PreviousPatient> {

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
    // Query current = patients.orderBy('accepted_at', descending: false);
    // current = current.orderBy('discharged_at', descending: true);
    // _patientStream = current.orderBy('discharged_at', descending: false).where('discharged_at', isNull: true).snapshots();
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot> (
      stream:FirebaseFirestore.instance.collection('hospitals')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('patient')
          .where('Status', isEqualTo: 'discharged')
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
                    DataColumn(label: Text('Name',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Age',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Gender',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Birthday',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                  ],
                  rows: snapshot.data!.docs.where((doc) => searchText.isEmpty ||
                      doc['Name'].toString().toLowerCase().contains(searchText.toLowerCase()))//||
                  //doc['Status'].toString().toLowerCase().contains(searchText.toLowerCase()))
                      .map((DocumentSnapshot doc) {
                    final rowData = doc.data() as Map<String, dynamic>;

                    List<String> listSymptoms = List<String>.from(rowData['Symptoms']);

                    // create view button widget
                    final viewButton = viewPatientInfo(context, rowData, doc, listSymptoms);

                    return DataRow(cells: [
                      DataCell(Center(child: Text(rowData['Name']))),
                      DataCell(Center(child: Text(rowData['Age'].toString()))),
                      DataCell(Center(child: Text(rowData['Sex']))),
                      DataCell(Center(child: Text(rowData['Birthday']))),
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
                        Column(
                          children: [
                            Text('Accepted Time'),
                            Text(data['accepted_at'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Column(
                          children: [
                            Text('Discharged Time'),
                            Text(data['discharged_at'],
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
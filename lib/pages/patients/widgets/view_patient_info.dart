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
    // Query current = patients.orderBy('accepted_at', descending: false);
    // current = current.orderBy('discharged_at', descending: true);
    // _patientStream = current.orderBy('discharged_at', descending: false).where('discharged_at', isNull: true).snapshots();
  }

  void getListService() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var service = userDoc['use_services'] as Map<String, dynamic>;
    var serviceNames = service.keys.toList();
    for (var name in serviceNames) {
      if (service[name]['availability'] != 0) { // Check if the value is not 0
        services.add(name); // Add the field name to the list
      }
    }
    services.add('None');
    // Add the list field value to myList
    user_services.addAll(List<String>.from(serviceNames));
  }

  Future<void> updateServiceInUse(String docId, String? newValue, String? prev) async {

    print(prev);
    CollectionReference hospitalsRef = FirebaseFirestore.instance.collection('hospitals');

// assume we have a document with ID 'user1' in the 'users' collection
    DocumentReference hospitalRef = hospitalsRef.doc(FirebaseAuth.instance.currentUser!.uid);

// get the document data
    //DocumentSnapshot userSnapshot = await userRef.get();

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
      }

      // decrement/increment the respective fields under the services map field
      if (prev != null && prev != newValue) {
        if (user_services.contains(prev)) {
          // decrement the field with the same name as previousValue
          hospitalRef.update({'use_services.$prev.availability': FieldValue.increment(1)});
        }
        if (user_services.contains(newValue)) {
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
                    DataColumn(label: Text('Service in Use',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    DataColumn(label: Text('Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                  ],
                  rows: snapshot.data!.docs.where((doc) => searchText.isEmpty ||
                      doc['Name:'].toString().toLowerCase().contains(searchText.toLowerCase()))//||
                      //doc['Status'].toString().toLowerCase().contains(searchText.toLowerCase()))
                      .map((DocumentSnapshot doc) {
                    final rowData = doc.data() as Map<String, dynamic>;
                    String prev = rowData['Service in use'];
                    List<String> listSymptoms = List<String>.from(rowData['Symptoms']);

                    // create view button widget
                    final viewButton = viewPatientInfo(context, rowData, doc, listSymptoms);
                    final serviceInUse = TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.black.withOpacity(0.04);
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.redAccent.withOpacity(0.12);
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        showDialog(
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
                                        onPressed: () {
                                          // Do something when the option is selected
                                          updateServiceInUse(doc.id,option, prev);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(rowData['Service in use']),
                    );

                    return DataRow(cells: [
                      DataCell(Center(child: Text(rowData['Status']))),
                      DataCell(Center(child: Text(rowData['Name:']))),
                      DataCell(Center(child: Text(rowData['Age'].toString()))),
                      DataCell(Center(child: Text(rowData['Sex']))),
                      DataCell(Center(child: Text(rowData['Birthday']))),
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
                            Text(data['Name:'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Column(
                          children: [
                            Text('Age'),
                            Text(data['Age'],
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

  // DropdownButton<String> buildDropdownButton2 (BuildContext context, selectedType, List<String> services, DocumentSnapshot<Object?> doc) {
  //   return DropdownButton<String>(
  //     value: selectedType,
  //     items: services.map((String service) {
  //       return DropdownMenuItem<String>(
  //         value: service,
  //         child: Text(service, style:TextStyle(fontWeight: FontWeight.bold )),
  //       );
  //     }).toList(),
  //     onChanged: (String? newValue) {
  //       setState(() {
  //         prev = selectedType;
  //         print(prev);
  //         selectedType = newValue;
  //         // update the service_in_use field in the data with the selected value
  //         //data['Service in use'] = newValue;
  //       });
  //       // call a function to update the data in Firestore
  //       updateServiceInUse(doc.id, newValue);
  //     },
  //   );
  //}
}
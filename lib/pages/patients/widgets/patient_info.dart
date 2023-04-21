import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/pages/overview/widgets/request_patient_info.dart';
import 'package:hospital_system/widgets/custom_text.dart';

class PatientInformation extends StatefulWidget {
  @override
  _PatientInformationState createState() => _PatientInformationState();
}

class _PatientInformationState extends State<PatientInformation> {

  final List<DataRow> rows = [];
  // create a list of available services for the dropdown
  //List<String> services = ['ambulance', 'emergency_room', 'general_ward']; // Replace with your actual list of services
  String selectedType = '';
  String prev = '';
  List<String> services = [];

  late final Stream<QuerySnapshot> _patientStream;

  @override
  void initState() {
    super.initState();
    getListService();
    updateServiceInUse;
    _patientStream = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('patient')
        .snapshots();
  }

  void getListService() async{
    DocumentSnapshot listServices = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    var service = listServices['use_services'] as Map<String, dynamic>;
    var serviceNames = service.keys.toList();
    // Add the list field value to myList
    services.addAll(List<String>.from(serviceNames));
  }

  void updateServiceInUse(String docId, String? newValue) async {
    // fetch the current patient document
    //DocumentSnapshot patientDoc = await FirebaseFirestore.instance
      //  .collection('hospitals')
        //.doc(FirebaseAuth.instance.currentUser!.uid)
        //.collection('patient')
        //.doc(docId)
        //.get();

    // get the current value of service_in_use field
    //String? previousValue = patientDoc['service_in_use'];

    // update the service_in_use field in Firestore
    FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('patient')
        .doc(docId)
        .update({'Service in use': newValue})
        .then((value) {
      print('Service in use updated');

      // decrement/increment the respective fields under the services map field
      if (prev != null && prev != newValue) {
        // decrement the field with the same name as previousValue
        FirebaseFirestore.instance
            .collection('hospitals')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'use_services.$prev.availability': FieldValue.increment(1),
          'use_services.$newValue.availability': FieldValue.increment(-1),

            });

        // increment the field with the same name as newValue
        //FirebaseFirestore.instance
        //    .collection('hospitals')
        //    .doc(FirebaseAuth.instance.currentUser!.uid)
        //    .update({'use_services.$newValue.availability': FieldValue.increment(-1)});
      }
    }).catchError((error) => print('Failed to update service in use: $error'));
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _patientStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        snapshot.data!.docs.forEach((DocumentSnapshot doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // create view button widget
          final viewButton = ElevatedButton(
            onPressed: () {

            },
            child: Text('View', style: TextStyle(decoration: TextDecoration.underline,),),
          );

          selectedType = data['Service in use'];
          print(services);
          // create a DropdownButton widget with current value and onChanged callback
          final dropdownButton = buildDropdownButton2(selectedType, services, doc);

          // create a DataRow from the data and add it to the list
          final row = DataRow(cells: [
            DataCell(Center(child: Text(data['Name']))),
            DataCell(Center(child: Text(data['Age'].toString()))),
            DataCell(Center(child: Text(data['Sex']))),
            DataCell(Center(child: Text(data['Birthday']))),
            DataCell(Center(child: viewButton)),
            DataCell(Center(child: dropdownButton)),
          ]);
          rows.add(row);
        });

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 100),
            child: Column(
              children: [
                SizedBox(
                  width: 10,
                ),
                CustomText(
                  text: "Patient Information",
                  color: darke,
                  weight: FontWeight.bold,
                ),
                SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                      DataColumn(label: Text('Age',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                      DataColumn(label: Text('Gender',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                      DataColumn(label: Text('Birthday',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                      DataColumn(label: Text('View Full Information',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                      DataColumn(label: Text('Service in Use',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                    ],
                    rows: rows,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DropdownButton<String> buildDropdownButton2(selectedType, List<String> services, DocumentSnapshot<Object?> doc) {
    return DropdownButton<String>(
      value: selectedType,
      items: services.map((String service) {
        return DropdownMenuItem<String>(
          value: service,
          child: Text(service, style:TextStyle(fontWeight: FontWeight.bold )),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          prev = selectedType;
          print(prev);
          selectedType = newValue;
          // update the service_in_use field in the data with the selected value
          //data['Service in use'] = newValue;
        });
        // call a function to update the data in Firestore
        updateServiceInUse(doc.id, newValue);
      },
    );
  }
}
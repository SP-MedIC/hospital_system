import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/pages/overview/widgets/request_patient_info.dart';
import 'package:hospital_system/widgets/custom_text.dart';

class RequestingPatients extends StatefulWidget {
  @override
  State<RequestingPatients> createState() => _RequestingPatientsState();
}

class _RequestingPatientsState extends State<RequestingPatients> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //final User? _currentUser = FirebaseAuth.instance.currentUser;
  String myString= "";
  String userId = FirebaseAuth.instance.currentUser!.uid;
  //DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  //String userName = documentSnapshot.data()['name'];

  late final Stream<QuerySnapshot> _patientrequestStream;



  @override
  void initState() {
    super.initState();
    getPatient();
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
  //final querySnapshot = await FirebaseFirestore.instance
  //    .collection('hospitals_patients')
  //    .where('Hospital User ID', isEqualTo: currentUserName)
  //    .get();
  //return myString;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('hospitals_patients')
          .where('Hospital User ID', isEqualTo: myString)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        //List<DocumentSnapshot> emergencyPatients = [];
        //List<DocumentSnapshot> priorityPatients = [];
        //List<DocumentSnapshot> nonUrgentPatients = [];

        //final userData = snapshot.data!.docs as Map<String, dynamic>;
        //final services = userData['services'];
        // Sort the documents based on "triage result" field
        snapshot.data!.docs.sort((a, b) {
          final String triageResultA = a.get('Triage Result') as String;
          final String triageResultB = b.get('Triage Result') as String;

          print("Triage Result A: $triageResultA");
          print("Triage Result B: $triageResultB");

          if (triageResultA == 'Emergency Case') {
            return -1;
          } else if (triageResultB == 'Emergency Case') {
            return 1;
          } else if (triageResultA == 'Priority Case') {
            return -1;
          } else if (triageResultB == 'Priority Case') {
            return 1;
          } else {
            return 0;
          }
        });


        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 50,
            horizontalMargin: 6,
            columns: [
              DataColumn2(
                  label: Text('Patient Name'),
                  size: ColumnSize.L,
              ),
              DataColumn(
                  label: Text('Age')
              ),
              DataColumn(
                  label: Text('Status')
              ),
              DataColumn(
                  label: Text('View')
              ),
            ],
            rows: snapshot.data!.docs.map((doc) {
              final patientName = doc['Name'];
              final age = doc['Age'];
              final triage_result = doc['Triage Result'];

              return DataRow(cells: [
                DataCell(Text(patientName)),
                DataCell(Text(age)),
                DataCell(Text(triage_result)),
                DataCell(
                  ElevatedButton(
                    child: Text('View'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(doc);
                        },
                      );
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}

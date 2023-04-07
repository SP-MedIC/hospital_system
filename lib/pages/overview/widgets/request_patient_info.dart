import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final DocumentSnapshot doc;
  final _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser!;

  CustomDialog(this.doc);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      //height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              1.0, // Move to right 5  horizontally
              1.0, // Move to bottom 5 Vertically
            ),
          )
        ],
      ),
      child: AlertDialog(
        title: Text(
          "PATIENT INFORMATION",
          style: TextStyle(
            color: Color(0xFFba181b),
            fontSize: 28.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
              child: Text('Name: ${doc['Name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                child: Text('Birthday: ${doc['Birthday']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                child: Text('Age: ${doc['Age']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                child: Text('Sex: ${doc['Sex']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                child: Text('Address: ${doc['Address']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                child: Text('Main Complaints: ${doc['Main Concerns']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 6),
                child: Column(
                  children: [
                    Text('Symptoms:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Padding(
                        padding: EdgeInsets.only(right: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var symptom in doc['Symptoms'].keys)
                              Text('• $symptom: ${doc['Symptoms'][symptom]}', style: TextStyle(fontSize: 16)),
                          ],
                      ),
                    ),
                  ],
                ),
            ),
            Container(
                child: Text('Triage Result: ${doc['Triage Result']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
            Container(
                child: Text('Travel Mode: ${doc['Travel Mode']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Accept'),
            onPressed: () {
              _updateStatusAndAcceptPatient(context);
            },
          ),
          TextButton(
            child: Text('Reject'),
            onPressed: () {
              _updateStatusAndRejectPatient(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatusAndAcceptPatient(BuildContext context) async {
    try {
      String serviceInUse = '';
      if (doc['Travel Mode'] == 'Ambulance' ) {
        // Get the license plate number of the ambulance from the current user's document
        //DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        //String licensePlateNumber = userDoc['use_service']['ambulance']['license_plate_number'];
        Map<String, dynamic> userDocData =
        (await FirebaseFirestore.instance.collection('hospitals').doc(currentUser.uid).get()).data()!;

        List<dynamic> ambulancesData = userDocData['use_services']['ambulances'];

        String licensePlateNumber = '';
        int ambulanceIndex = 0;

        for (int i = 0; i < ambulancesData.length; i++) {
          Map<String, dynamic> ambulanceData = ambulancesData[i];

          if (ambulanceData['availability'] == 'available') {
            licensePlateNumber = ambulanceData['license_plate_number'];
            ambulanceData['availability'] = 'unavailable';
            ambulanceIndex = i;
            ambulancesData[ambulanceIndex] = ambulanceData;
            break;
          }
        }
        if (licensePlateNumber.isNotEmpty) {
          // Perform further actions with the licensePlateNumber
          print('License Plate Number: $licensePlateNumber');

          // Update the ambulance data in the user's document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'use_services.ambulances': ambulancesData});
        } else {
          print('No available ambulance found.');
        }

        // Set the service in use to the license plate number of the ambulance
        serviceInUse = licensePlateNumber;

        // Update the service_in_use field of the patient's document with the license plate number
        await FirebaseFirestore.instance
            .collection('hospitals_patients')
            .doc(doc.id)
            .update({'Status': 'accepted'});
      } else {
        // If travel mode is not ambulance, just update the status field
        await FirebaseFirestore.instance
            .collection('hospitals_patients')
            .doc(doc.id)
            .update({'Status': 'accepted'});
      }

      // Add the entire document as a new subdocument of the `patients` collection under the hospital's document
      //final patientRef = FirebaseFirestore.instance.collection('hospitals').doc(currentUser!.uid).collection('patient');
      //await patientRef.add(doc.data());
      //await FirebaseFirestore.instance
      //    .collection('hospitals')
      //    .doc(currentUser.uid)
      //    .collection('patient')
      //    .add(doc.data());

      final userDoc = {
        'Name': doc['Name'],
        'Triage Result': doc['Triage Result'],
        'Age': doc['Age'],
        'Sex': doc['Sex'],
        'Address': doc['Address'],
        'Birthday': doc['Birthday'],
        'Main Concerns': doc['Main Concerns'],
        'Symptoms': doc['Symptoms'],
        'Service in use': serviceInUse.toString(),
        'accepted_at': Timestamp.now(),
      };

      _firestore
          .collection('hospitals')
          .doc(currentUser.uid)
          .collection('patients')
          .add(userDoc)
          .then((value) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient accepted')),
        );
        }).catchError((error) {
          print('Error adding document to user collection: $error');
        });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient accepted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _updateStatusAndRejectPatient(BuildContext context) {

    //final FirebaseFiestore.intance.collection.doc(doc.id).update({"Status":"accepted"});
    final updatedDoc = {
      'Status': 'rejected',
    };

    _firestore
        .collection('hospitals_patients')
        .doc(doc.id)
        .update(updatedDoc)
        .then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }).catchError((error) {
      print('Error updating document: $error');
    });
  }
}

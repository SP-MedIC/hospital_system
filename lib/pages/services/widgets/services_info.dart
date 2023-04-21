import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/pages/overview/widgets/info_cards.dart';

class ServicesInformation extends StatefulWidget {

  @override
  State<ServicesInformation> createState() => _ServicesInformationState();
}

class _ServicesInformationState extends State<ServicesInformation> {

  late final Stream<DocumentSnapshot> _userStream;
  TextEditingController totalController = TextEditingController();
  String selectedName = '';

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser!;
    _userStream = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(currentUser.uid)
        .snapshots();
  }

  @override
  void dispose() {
    totalController.dispose();
    super.dispose();
  }
  void editDialog(String serviceName, int currentTotal) {
    selectedName = serviceName;
    totalController.text = currentTotal.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Total'),
        content: Column(
          children: [
            Text('Service: $selectedName'),
            TextFormField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (totalController.text.isNotEmpty) {
                int newTotal = int.tryParse(totalController.text) ?? 0;
                await updateTotal(selectedName, newTotal);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> updateTotal(String serviceName, int newTotal) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final DocumentReference docRef = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(currentUser.uid);

    try {
      await docRef.update({
        'use_services.$serviceName.total': newTotal,
        'use_services.$serviceName.availability': newTotal,
      });
    } catch (e) {
      print('Error updating total: $e');
    }
  }


  //final User? user = FirebaseAuth.instance.currentUser;
  //final String userId = FirebaseAuth.instance.currentUser!.uid;
  //final Stream<DocumentSnapshot> userStream = FirebaseFirestore.instance
  //    .collection('hospitals')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //    .snapshots();

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        children: [
          StreamBuilder(
            stream: _userStream,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              else if(snapshot.connectionState == ConnectionState.waiting){
                return const CircularProgressIndicator();
              }

              else if (!snapshot.hasData) {
                return const Center(child: Text('Data Unavailable'));
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;
              var services = data['use_services'] as Map<String, dynamic>;
              var serviceNames = services.keys.toList();
              var availability = services.values
                  .map((service) => service['availability'])
                  .toList();
              var total = services.values.map((service) => service['total']).toList();
              //final servicesList = services.values.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Service')),
                        DataColumn(label: Text('Availability')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Update Total')),
                      ],
                      rows: List.generate(
                        serviceNames.length,
                            (index) {
                              String serviceName = serviceNames[index];
                              int currentTotal = total[index];
                              return DataRow(
                          cells: [
                            DataCell(Text(serviceNames[index])),
                            DataCell(Text(availability[index].toString())),
                            DataCell(Text(total[index].toString())),
                            DataCell(
                              ElevatedButton(
                                onPressed: (){
                                  editDialog(serviceName, currentTotal);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.deepOrange.shade600, // set the button's background color
                                  onPrimary: Colors.white, // set the text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0), // set button's border radius
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Text('Edit'),
                                ),
                              ),
                            ),
                          ],
                        );
                              },
                      ),
                    )
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

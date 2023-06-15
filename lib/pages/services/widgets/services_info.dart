import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


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

  //Dialog for edit total number
  void editDialog(String serviceName, int currentTotal) {
    selectedName = serviceName;
    totalController.text = currentTotal.toString();

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Edit Total')),
        content: Container(
          constraints: BoxConstraints(maxHeight: 150, maxWidth: 150),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Text("Service: $selectedName"),
                SizedBox(height: 10),
                TextFormField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total',
                  ),
                  validator: (value) {
                    final numeric = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                    if (value == null || value.isEmpty) {
                      return "* Required";
                    } else if (!numeric.hasMatch(value)) {
                      return "Please enter a valid number.\nEnter 0 if None.";
                    }
                    return null;
                  },
                ),
                Text(
                  '(Please input the total number of $selectedName/Beds to be offered)',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (totalController.text.isNotEmpty) {
                await Future.delayed(Duration(seconds: 2));
                if (formKey.currentState?.validate() ?? false) {
                  int newTotal = int.tryParse(totalController.text) ?? 0;
                  await updateTotal(selectedName, newTotal);
                }
                Navigator.pop(context);
              }
            },
            child: Text('Save'), // Display "Save" text
          ),
        ],
      ),
    );
  }


//update the total and the number of availability of chosen service
  Future<void> updateTotal(String serviceName, int newTotal) async {
    //getting the current user document
    final currentUser = FirebaseAuth.instance.currentUser!;
    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(currentUser.uid);

    try {
      //get the latest update of data
      final DocumentSnapshot userSnapshot = await userDoc.get();
      final Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;

      //check whether the document contains the field use_services
      if (data != null && data.containsKey('use_services')) {
        final Map<String, dynamic>? useServices = data['use_services'] as Map<String, dynamic>?;

        //check whether the field has another field with the service name
        if (useServices != null && useServices.containsKey(serviceName)) {
          final Map<String, dynamic>? serviceData = useServices[serviceName] as Map<String, dynamic>?;

          //check whether the total field exist in the service
          if (serviceData != null && serviceData.containsKey('total')) {

            //assign values to variable
            final int currentTotal = serviceData['total'] as int;
            final int currentAvailable = serviceData['availability'] as int;

            //get the current availability given the new total
            final int availability = (newTotal - currentTotal) + currentAvailable;

            //update the document
            await userDoc.update({
              'use_services.$serviceName.total': newTotal,
              'use_services.$serviceName.availability': availability,
            });
          }
        }
      }
    } catch (e) {
      print('Error updating total: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
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

            //load the document
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var services = data['use_services'] as Map<String, dynamic>; //get the services
            var serviceNames = services.keys.toList(); //get the services names

            //get the availability and total of each services put in list
            var availability = services.values
                .map((service) => service['availability'])
                .toList();
            var total = services.values.map((service) => service['total']).toList();

            //create a data table
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Service',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                        DataColumn(label: Text('Available',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                        DataColumn(label: Text('Total',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                        DataColumn(label: Text('Update Total',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
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
                            //edit button for each services
                            DataCell(
                              TextButton(
                                onPressed: (){
                                  editDialog(serviceName, currentTotal);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.deepOrange.shade600, // set the text color
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
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

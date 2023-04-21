
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:path/path.dart';

class patientInfo
{
static void show(BuildContext context, DocumentSnapshot doc, String triageResult) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final List<dynamic> symptoms = data['Symptoms'] as List<dynamic>; // Extract symptoms array field
      return AlertDialog(
        title: Text('Patient Information'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${data['Name']}'),
            Text('Age: ${data['Age']}'),
            Text('Sex: ${data['Sex']}'),
            Text('Birthday: ${data['Birthday']}'),
            Text('Triage Result: $triageResult'),
            SizedBox(height: 16.0),
            Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              itemCount: symptoms.length,
              itemBuilder: (BuildContext context, int index) {
                return Text('${index + 1}. ${symptoms[index]}');
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: Text('Reject'),
            onPressed: () {
              // Handle Reject button press
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Accept'),
            onPressed: () {
              // Handle Accept button press
              // You can add your logic for accepting the document here
            },
          ),
        ],
      );
    },
  );
}
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_system/pages/settings/widgets/edit_setting.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name = "";
  String? _email = "";
  String? _serviceName = "";
  String? _serviceDescription = "";
  String? _phone = "";
  String? _address= "";
  String? image = "";
  File? imageXFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('hospitals').doc(uid)
        .get()
        .then((snapshot) {
          if(snapshot.exists){
            setState(() {
              _name = snapshot.data()!['Name'];
              _email = snapshot.data()!['email'];
              _address = snapshot.data()!['Address'];
              _phone = snapshot.data()!['Contact_num'];
              _serviceName = snapshot.data()!['services']['ambulance'];
              _serviceDescription = snapshot.data()!['services']['emergency_room'];
              image = snapshot.data()!['Pic_url'];
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Container(
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                minRadius: 60,
                child: CircleAvatar(
                  radius:50,
                  backgroundImage: NetworkImage(image!),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Center(
            child: Column(
              children: [
                Text(
                  'Name'+ _name!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    //color: Colors.black45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Address'+ _address!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _phone!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _email!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _serviceName!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _serviceDescription!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top:20, bottom: 20),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 10.0),
              child: RawMaterialButton(
                fillColor: const Color(0xFFba181b),
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: Color(0xFFba181b)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditSettings()));
                },
                child: const Text('Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

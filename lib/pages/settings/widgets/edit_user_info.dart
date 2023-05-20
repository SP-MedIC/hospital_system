import 'dart:core';
import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:get/get.dart';
import 'package:hospital_system/layout.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

import '../../../controllers/authentication_controller.dart';

class EditSettings extends StatefulWidget {
  const EditSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditSettingsState();
  }
}

class _EditSettingsState extends State<EditSettings> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final currentUser = FirebaseAuth.instance.currentUser;

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final addressController = TextEditingController();


  //String imageUrl = '';
  //String _profilePictureUrl = "";
  String addressError = "";
  String imgUrl = "";
  String selectedType = '';
  String latitude = '';
  String longitude = '';
  bool updating = false;

  @override
  void initState() {
    super.initState();
    // Retrieve current user's information from Firestore and set the initial values
    getUserProfileInfo();
  }

  void getUserProfileInfo() async {
    //final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('hospitals').doc(currentUser!.uid).get();
    String email = FirebaseAuth.instance.currentUser!.email!;
    setState(() {
      nameController.text = userData['Name'];
      passwordController.text = userData['password'];
      numberController.text = userData['Contact_num'];
      addressController.text = userData['Address'];
      imgUrl = userData['Pic_url'].toString();
      selectedType = userData['type'];

    });
  }

  uploadToStorage() {
    final user = FirebaseAuth.instance.currentUser!.uid;
    FileUploadInputElement input = FileUploadInputElement();
    input.accept = '.png,.jpg';
    FirebaseStorage fs = FirebaseStorage.instance;
    input.click();
    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) async {
        var snapshot = await fs.ref().child('profile_pictures/$user/${DateTime.now().millisecondsSinceEpoch}').putBlob(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imgUrl = downloadUrl;
        });
      });
    });
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool haveAgreed = false;
  bool isHiddenPassword = true;

  List<String> type = ['Private', 'Public'];

  void _togglePassword() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }


  Future submit() async {

    String email = FirebaseAuth.instance.currentUser!.email!;
    //GeoCode geoCode = GeoCode();
    String address = addressController.text.trim();
    String password = passwordController.text.trim();

    // Simulate an asynchronous operation
    setState(() {
      updating = true; // Set updating to true when submit() is called
    });

    // Perform the submit operation
    await Future.delayed(Duration(seconds: 2));

    try {
      GeoData data = await Geocoder2.getDataFromAddress(
          address: address,
          googleMapApiKey: "AIzaSyAS8T5voHU_bam5GCQIELBbWirb9bCZZOA");
      print("Latitude: ${data.latitude}");
      print("Longitude: ${data.longitude}");
      latitude = data.latitude.toString();
      longitude = data.longitude.toString();
      print(latitude.runtimeType);
      print(longitude.runtimeType);

      await FirebaseAuth.instance.currentUser!.updatePassword(password);

      FirebaseFirestore.instance.collection('hospitals').doc(currentUser!.uid).update({
        'Name':nameController.text,
        'Address': addressController.text,
        'Contact_num': numberController.text,
        'password':passwordController.text,
        'type':selectedType,
        'Pic_url':imgUrl,
        'Location':{
          'Latitude': latitude,
          'Longitude':longitude,
        }
      });
      addressError = "";
    } catch (e) {
      addressError = "Please enter a valid address format (Street, Barangay, Municipality, City, Province, Country)";
      print(e);
    }

    setState(() {
      updating = false; // Set updating back to false after the operation is complete
    });

  }


  bool passwordConfirmed(){
    if(passwordController.text.trim() == confirmController.text.trim()){
      return true;
    }else{
      return false;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 450,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        //margin: const EdgeInsets.fromLTRB(0.0, 60.0, 0.0,0.0),
                        child: const Text(
                          'Edit Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFFba181b),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          uploadToStorage(); // Call the _pickImage() function when the profile picture is tapped
                        },
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.transparent,
                          backgroundImage: imgUrl.toString() == ""
                              ? null
                              : NetworkImage(imgUrl),
                          child: imgUrl.toString() == ""
                              ? Icon(Icons.add_a_photo, color: Colors.grey[500], size: 35,)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 8.0),
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFba181b)),
                          ),
                          labelText: 'Full Name',
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "* Required";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
                      child: TextFormField(
                        controller: numberController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(color: Color(0xFFba181b)),
                          ),
                          labelText: 'Contact Number',
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "* Required";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Color(0xFFba181b)),
                              ),
                              labelText: 'Address',
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "* Required";
                              }
                              return null;
                            },
                          ),
                          Visibility(
                            visible: addressController.text.isNotEmpty && addressError != "",
                            child: Text(
                              addressError,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
                      child: TextFormField(
                          controller: passwordController,
                          obscureText: isHiddenPassword,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Color(0xFFba181b)),
                            ),
                            labelText: 'Password',
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  _togglePassword();
                                },
                                //isHiddenPassword = !isHiddenPassword;
                                child: Icon(
                                    isHiddenPassword? Icons.visibility
                                        : Icons.visibility_off)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "* Required";
                            }
                            if (value.trim().length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          }
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
                      child: TextFormField(
                          controller: confirmController,
                          obscureText: isHiddenPassword,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Color(0xFFba181b)),
                            ),
                            labelText: 'Confirm Password',
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  _togglePassword();
                                },
                                child: Icon(
                                    isHiddenPassword? Icons.visibility
                                        : Icons.visibility_off)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "* Required";
                            }else if(!passwordConfirmed()){
                              return "Passwords do not match";
                            }
                            return null;
                          }
                      ),
                    ),
                    const Text("Hospital Type:"),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Color(0xFFba181b))
                            )),
                        value: selectedType,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: type.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedType = newValue!;
                          });
                        },
                      ),
                    ),
                    Container(
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
                          if (!updating) {
                            // Prevent button press if isLoading is true
                            if (_formKey.currentState!.validate()) {
                              submit();
                            }
                          }
                          // if (_formKey.currentState!.validate()){
                          //   submit();
                          // }
                        },
                        child: updating
                            ? CircularProgressIndicator( // Show CircularProgressIndicator when updating is true
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
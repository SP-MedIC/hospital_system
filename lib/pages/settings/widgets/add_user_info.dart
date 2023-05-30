import 'dart:core';
import 'dart:html';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:hospital_system/controllers/authentication_controller.dart';
import 'package:hospital_system/layout.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:hospital_system/widgets/top_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class AddUserInformation extends StatefulWidget {
  const AddUserInformation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddUserInformationState();
  }
}

class _AddUserInformationState extends State<AddUserInformation> {

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final currentUser = FirebaseAuth.instance.currentUser;

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final addressController = TextEditingController();
  final emergencyController = TextEditingController();
  final privateController = TextEditingController();
  final operatingController = TextEditingController();
  final generalController = TextEditingController();
  final laborRoomController = TextEditingController();


  //String imageUrl = '';
  String _profilePictureUrl = "";
  String addressError = "";
  String latitude = "";
  String longitude = "";
  bool showPasswordError = false;
  bool showServiceError = false;

  @override
  void initState() {
    super.initState();
  }
  String imgUrl = "";

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
  String selectedType = 'Public';

  void _togglePassword() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }


  Future submit() async {
    final LoginController loginController = Get.find();

    String email = FirebaseAuth.instance.currentUser!.email!;
    print(email);
    String address = addressController.text.trim();
    String password = passwordController.text.trim();

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

      FirebaseFirestore.instance.collection('hospitals').doc(currentUser!.uid).set({
        'Name':nameController.text.trim(),
        'email': email,
        'Address': addressController.text,
        'Contact_num': numberController.text.trim(),
        'password':passwordController.text.trim(),
        'type':selectedType,
        'Pic_url':imgUrl,
        'Location': {
          'Latitude': latitude,
          'Longitude': longitude,
        },
        'use_services':{
          'Emergency Room':{ //int.tryParse(totalController.text)
            'availability':int.tryParse(emergencyController.text),
            'total':int.tryParse(emergencyController.text),
          },
          'General Ward':{
            'availability':int.tryParse(generalController.text),
            'total':int.tryParse(generalController.text),
          },
          'Operating Room':{
            'availability':int.tryParse(operatingController.text),
            'total':int.tryParse(operatingController.text),
          },
          'Private Room':{
            'availability':int.tryParse(privateController.text),
            'total':int.tryParse(privateController.text),
          },
          'Labor Room':{
            'availability':int.tryParse(laborRoomController.text),
            'total':int.tryParse(laborRoomController.text),
          },
        }

      });

      addressError = "";
      loginController.doLogout();
      // if (currentUser != null) {
      //   //signed in
      //   if (!mounted) return;
      //   loginController.doLogout();
      // }
    } catch (e) {
      addressError = "Please enter a valid address format (Street, Barangay, Municipality, City, Province, Country)";
      print(e);
    }

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
        body: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: SingleChildScrollView(
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
                            'Setting up your account profile',
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
                                if (value == null || value.isEmpty) {
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
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                "Services",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            servicesform("Emergency Room", emergencyController),
                            SizedBox(height: 8,),
                            servicesform("General Ward", generalController),
                            SizedBox(height: 8,),
                            servicesform("Private Room/s", privateController),
                            SizedBox(height: 8,),
                            servicesform("Operating Room/s", operatingController),
                            SizedBox(height: 8,),
                            servicesform("Labor Room", laborRoomController),
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
                            },
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
                            if (_formKey.currentState!.validate()){
                              submit();
                            }
                          },
                          child: const Text('Submit',
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
          ),
        )
    );
  }

  Container servicesform(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.only(left: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number, // Set the keyboard type to number
        //inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits as input
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFFba181b)),
          ),
          labelText: label,
        ),
        validator: (value) {
          final numeric =
          RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
          if (value == null || value.isEmpty) {
            return "* Required";
          } else if (!numeric.hasMatch(value)){
            return "Please enter a valid number. Enter 0 if None.";
          }
          return null;
        },
      ),
    );
  }
}
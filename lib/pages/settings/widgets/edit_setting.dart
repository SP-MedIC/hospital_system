import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hospital_system/controllers/authentication_controller.dart';
import 'package:hospital_system/layout.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

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
  final emergencyController = TextEditingController();
  final privateController = TextEditingController();
  final ambulanceController = TextEditingController();
  final maternalController = TextEditingController();
  final generalController = TextEditingController();
  final emailController = TextEditingController();

  //String imageUrl = '';
  String _profilePictureUrl = "";
  XFile? _image;
  XFile? get image => _image;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool haveAgreed = false;
  bool isHiddenPassword = true;

  List<String> type = ['Private', 'Public'];
  String selectedType = 'Public';


  @override
  void initState() {
    super.initState();
    // Retrieve current user's information from Firestore and set the initial values
    // for the form fields
    getUserProfileInfo();
  }

  void getUserProfileInfo() async {
    final userData = await FirebaseFirestore.instance.collection('hospitals').doc(currentUser!.uid).get();
    String email = FirebaseAuth.instance.currentUser!.email!;
    setState(() {
      nameController.text = userData['Name'];
      passwordController.text = userData['password'];
      numberController.text = userData['Contact_num'];
      addressController.text = userData['Address'];
      emailController.text = email;
      _profilePictureUrl = userData['Pic_url'].toString();
    });
    print(_profilePictureUrl);
  }

  Future<void> _pickImage() async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    // Open the image picker
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Create the file metadata
      final metadata = SettableMetadata(contentType: "image/jpeg");
      // Upload the image to Firebase storage
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$user/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final snapshot = await storageRef.putFile(file,metadata).whenComplete(() {
        return null;
      });

      // Get the URL of the uploaded file
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Update the _profilePictureUrl state variable with the new URL
      setState(() {
        _profilePictureUrl = imageUrl;
      });
      print(_profilePictureUrl);
    }
  }


  void _togglePassword() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }


  Future submit() async {
    //if(passwordConfirmed()){
      //String uid = FirebaseAuth.instance.currentUser!.uid;
    final LoginController loginController = Get.find();
    String email = FirebaseAuth.instance.currentUser!.email!;
    print(email);
    FirebaseFirestore.instance.collection('hospitals').doc(currentUser!.uid).update({
      'Name':nameController.text,
      //'email': email,
      'Address': addressController.text,
      'Contact_num': numberController.text,
      'password':passwordController.text,
      'type':selectedType,
      'Pic_url': _profilePictureUrl,

    });
      //Get.offAndToNamed(authenticationPageRoute);
    //}

    if (currentUser != null) {
      // signed in
      if (!mounted) return;
      loginController.doLogout();
    }
    //} else {
    //  if (!mounted) return;
    //  Navigator.pop(context as BuildContext);
    //}

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
                        onTap: (){
                          _pickImage();
                        },
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.transparent,
                          backgroundImage: _profilePictureUrl.toString() == ""
                              ? null
                              : NetworkImage(_profilePictureUrl),
                          child: _profilePictureUrl.toString() == ""
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
                      child: TextFormField(
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
        )
    );
  }
}
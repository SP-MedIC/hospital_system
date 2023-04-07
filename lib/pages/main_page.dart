import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/layout.dart';
import 'package:hospital_system/pages/general_screen.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'MedIC',
              home: Sitelayout(),
            );
          }else {
            return LoginPage();
          }
        },

      ),
    );
  }
}

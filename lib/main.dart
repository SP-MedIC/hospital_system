import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/controllers/menu_controller.dart';
import 'package:hospital_system/controllers/navigation_controller.dart';
import 'package:hospital_system/layout.dart';
import 'package:hospital_system/pages/authentication/authentication.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:hospital_system/pages/general_screen.dart';
import 'package:hospital_system/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hospital_system/pages/overview/widgets/requesting_patients.dart';
import 'package:hospital_system/pages/patients/widgets/patient_info.dart';
import 'package:hospital_system/pages/settings/settings.dart';
import 'package:hospital_system/routing/routes.dart';
//import 'controllers/auth_controller.dart';
import 'firebase_options.dart';



void main() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(CustomMenuController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: authenticationPageRoute,
      getPages: [
        GetPage(name: rootRoute, page: (){
          return Scaffold(
            body: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot){
                if (snapshot.hasData){
                  return Sitelayout();
                }else {
                  return LoginPage();
                }
              },
            ),
          );
        }), //GetPage(name: authenticationPageRoute, page: () => AuthenticationPage()),
      ],
      debugShowCheckedModeBanner: false,
      title: 'MedIC',
      //home: MainPage(),
      theme: ThemeData(
        scaffoldBackgroundColor: light,
        textTheme: GoogleFonts.mulishTextTheme(
            Theme.of(context).textTheme
        ).apply(
          bodyColor: Colors.black45,
        ),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        }),
        primaryColor: Colors.blue,
      ),
    );
  }
}


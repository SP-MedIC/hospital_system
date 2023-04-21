import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/controllers/authentication_controller.dart';
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
  Get.put(LoginController());
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
        GetPage(name: authenticationPageRoute, page: () => GetBuilder<LoginController>(
        builder: (loginController) {
          if (loginController.isLoggedIn.value) {
            // Show Home Page if logged in
            return Sitelayout();
          } else {
            // Show Login Page if not logged in
            return LoginPage();
          }
        },
      )
      //binding: LoginBinding(),
    ),
        GetPage(name: rootRoute, page: (){
          return Sitelayout();
        },
          //binding: HomeBinding(),
        ),

      ],
      debugShowCheckedModeBanner: false,
      title: 'MedIC',
      //home: MainPage(),
      theme: ThemeData(
        scaffoldBackgroundColor: light,
        textTheme: GoogleFonts.mulishTextTheme(
            Theme.of(context).textTheme
        ).apply(
          bodyColor: Colors.black,
        ),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        }),
        primaryColor: Colors.indigoAccent,
      ),
    );
  }
}


class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Bind LoginController to its corresponding class
    Get.put(LoginController());
  }
}


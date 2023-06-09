import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/controllers/authentication_controller.dart';
import 'package:hospital_system/controllers/menu_controller.dart';
import 'package:hospital_system/controllers/navigation_controller.dart';
import 'package:hospital_system/layout.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hospital_system/routing/routes.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/error_404.dart';




void main() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(CustomMenuController());
  Get.put(NavigationController());
  Get.put(LoginController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: checkLoginStatus(),
    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); // Show a loading indicator while retrieving login status
      }

      bool isLoggedIn = snapshot.data ?? false;
      return GetMaterialApp(
        initialRoute: isLoggedIn ? rootRoute : authenticationPageRoute,
        getPages: [
          GetPage(name: authenticationPageRoute, page: () =>
              GetBuilder<LoginController>(
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
          ),
          GetPage(name: rootRoute, page: () {
            return Sitelayout();
          },
          ),
          GetPage(name: errorPageRoute, page: () => ErrorPage()),
        ],
        unknownRoute: GetPage(name: errorPageRoute, page: () => ErrorPage()),
        debugShowCheckedModeBanner: false,
        title: 'MedIC',
        //home: MainPage(),
        theme: ThemeData(
          scaffoldBackgroundColor: light,
          textTheme: GoogleFonts.mulishTextTheme(
              Theme
                  .of(context)
                  .textTheme
          ).apply(
            bodyColor: Colors.black,
          ),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          }),
          primaryColor: active,
        ),
      );
    },
    );
  }
}


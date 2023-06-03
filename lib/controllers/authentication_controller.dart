import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_system/pages/settings/widgets/add_user_info.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/controllers.dart';

class LoginController extends GetxController {
  // Reactive variables for email and password
  RxString email = ''.obs;
  RxString password = ''.obs;

  // Reactive variable for login status
  RxBool isLoggedIn = false.obs;

  // Reactive variable for error message
  RxString errorMessage = ''.obs;

  RxString status = ''.obs;

  // login
  void doLogin(String email, String password) async {
    try {
      // Perform authentication with email and password using Firebase Authentication
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email, password: password);

      // Set isLoggedIn to true if authentication is successful
      isLoggedIn.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Clear error message
      errorMessage.value = '';

      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Check if the user's UID is a document in the 'hospitals' collection
      DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('hospitals').doc(uid).get();

      if (documentSnapshot.exists) {
        // If the document exists, navigate to the home page
        Get.offAndToNamed(rootRoute);
      } else {
        if (!email.endsWith('medic.com')) {
          // Redirect to another page if the email doesn't end with "medic.com"
          Get.toNamed(errorPageRoute);
        }else{
          // User UID not found in "hospitals" collection, navigate to settings page
          Get.to(() => AddUserInformation());
        }
      }

    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exception
      if (e.code == 'user-not-found') {
        errorMessage.value = 'User not found. Please check your email and password.';
        print('User not found. Please check your email and password.');
      } else if (e.code == 'wrong-password') {
        errorMessage.value = 'Wrong password. Please check your email and password.';
        print('Wrong password. Please check your email and password.');
      } else {
        errorMessage.value = 'Error: ${e.message}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    }
  }

  // logout
  void doLogout() async {
    isLoggedIn.value = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    menuController.changeActiveitemTo(sideMenuItemRoutes.first.name);
    Get.offAllNamed(authenticationPageRoute);
  }

  void doCheckEmail(String email) async{
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((value) {

          status.value = "Password reset email sent";
        })
        .catchError((e) {
          status.value = "Failed to send password reset email";
        });
  }
}



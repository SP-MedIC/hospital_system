import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_system/pages/settings/widgets/add_user_info.dart';
import 'package:hospital_system/routing/routes.dart';

class LoginController extends GetxController {
  // Reactive variables for email and password
  RxString email = ''.obs;
  RxString password = ''.obs;

  // Reactive variable for login status
  RxBool isLoggedIn = false.obs;

  // Reactive variable for error message
  RxString errorMessage = ''.obs;

  // Method to handle login logic
  void doLogin(String email, String password) async {
    try {
      // Perform authentication with email and password using Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email, password: password);

      // Set isLoggedIn to true if authentication is successful
      isLoggedIn.value = true;

      //Get.offAndToNamed(rootRoute);
      // Get the logged-in user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Check if the user's UID is a document in the 'hospitals' collection
      DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('hospitals').doc(uid).get();

      if (documentSnapshot.exists) {
        // If the document exists, navigate to the home page
        Get.offAndToNamed(rootRoute);
      } else {
        // User UID not found in "hospitals" collection, navigate to settings page
        Get.to(() => AddUserInformation());
      }

      // Clear error message
      errorMessage.value = '';
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication exception
      if (e.code == 'user-not-found') {
        print('User not found. Please check your email and password.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password. Please check your email and password.');
      } else {
        print('Error: ${e.message}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Method to handle logout logic
  void doLogout() {
    // Perform logout logic
    // Replace this with your actual logout logic
    isLoggedIn.value = false;
    Get.offAndToNamed(authenticationPageRoute);
  }
}

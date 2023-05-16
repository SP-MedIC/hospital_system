import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/controllers/authentication_controller.dart';
import 'package:hospital_system/pages/authentication/authentication.dart';
import 'package:hospital_system/routing/routes.dart';



class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text('Medic'),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/img_uppernavbar.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: darke),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "404- Page Not Found",
              style: TextStyle(fontSize: 40, color: Colors.red.shade900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'We apologize for any inconvenience, but the user version of the system is currently not available on our website.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'We are continuously working on improving and expanding our services, and we appreciate your understanding and patience.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'If you have any questions or need further assistance, please feel free to contact our support team.',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the login page
                loginController.doLogout();
              },
              child: Text('Go Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

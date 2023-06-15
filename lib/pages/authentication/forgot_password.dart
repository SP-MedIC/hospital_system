import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/style.dart';
import '../../controllers/authentication_controller.dart';


//Forgot Password page
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final _formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();


  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Bind the LoginController to the ForgotPassword page
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 50.0),
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png',),
                    opacity: 0.4,
                    fit: BoxFit.cover,)
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 450,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 20.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Received email to Reset Password",
                          style: TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20,),
                        Obx(() {
                          final statusMessage = loginController.status.value;
                          if (statusMessage == "Password reset email sent") {
                            return Text(
                              statusMessage,
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16.0,
                              ),
                            );
                          } else if(statusMessage == "Failed to send password reset email"){
                            return Text(
                              statusMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                              ),
                            );
                          } else {
                            return SizedBox.shrink(); // Return an empty SizedBox if no error message
                          }
                        }),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: const BorderSide(color: Color(0xFFba181b)),
                            ),
                            labelText: 'Email',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return "* Required";
                            }else if(!EmailValidator.validate(value)){
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(60.0, 20.0, 60.0, 20.0),
                          child: RawMaterialButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            fillColor: active,
                            elevation: 0.0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: active),
                            ),
                            onPressed: () {
                              loginController.doCheckEmail(emailController.text.trim());
                            },

                            child: const Text('Reset Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
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
          ],
        ),
      ),
    );
  }
}

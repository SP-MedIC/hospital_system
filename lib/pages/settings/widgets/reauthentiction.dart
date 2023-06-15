import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReauthenticationDialog extends StatelessWidget {
  final VoidCallback submitFunction;

  const ReauthenticationDialog({required this.submitFunction});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final currentPasswordController = TextEditingController();

    return AlertDialog(
      title: Text('Re-authentication Required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: currentPasswordController,
            decoration: InputDecoration(labelText: 'Current Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final email = emailController.text.trim();
            final currentPassword = currentPasswordController.text.trim();

            // Perform reauthentication
            final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
            try {
              await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
              submitFunction();
              Navigator.of(context).pop(); // Close the dialog
            } catch (e) {
              // Handle reauthentication error
              print(e);
              Navigator.of(context).pop(); // Close the dialog
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Reauthentication Failed'),
                    content: Text('Invalid email or password. Please try again.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the error dialog
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

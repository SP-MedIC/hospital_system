import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/pages/settings/widgets/edit_setting.dart';
import 'package:hospital_system/widgets/custom_text.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  late String _profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(top:
                ResponsiveWidget.isSmallScreen(context) ? 56 : 6
                ),
                child: CustomText(
                  text: menuController.activeItem.value,
                  size: 24,
                  weight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            ],
          ),
        );
        }),
        Expanded(
            child: Container(
              child: EditSettings(),
            )
        ),
      ],
    );
  }
}

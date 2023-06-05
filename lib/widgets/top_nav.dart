import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/controllers/authentication_controller.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/widgets/custom_text.dart';

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState>key, userName, userImage) {

  final LoginController loginController = Get.find();

  return AppBar(
      leading: !ResponsiveWidget.isSmallScreen(context) ?
      Row(
        children: [
          Container(
            padding: EdgeInsets.only(left: 14),
            child: Text("Medic",style: TextStyle(color: lightGrey),),
          )
        ],
      ): IconButton(
          icon: Icon(Icons.menu),
          onPressed: (){
            key.currentState!.openDrawer();
          },),
      elevation: 0,
      title:  Row(
        children: [
          Visibility(
              child: CustomText(text: userName, color: light, size: 20, weight: FontWeight.bold )
          ),
          Expanded(child: Container(),),
          IconButton(
              onPressed: (){
                loginController.doLogout();
              },
              icon: Icon(Icons.exit_to_app, color:darke.withOpacity(.7)),
          ),
          Container(
            width: 2,
            height: 25,
            color: lightGrey,
          ),

          Container(
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(2),
              child: CircleAvatar(
                backgroundImage: NetworkImage(userImage),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
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
    );
}
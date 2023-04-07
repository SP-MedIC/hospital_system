import 'package:flutter/material.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:hospital_system/widgets/custom_text.dart';
import 'package:hospital_system/widgets/side_menu_items.dart';
import 'package:hospital_system/controllers/navigation_controller.dart';
import 'package:get/get.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Container(
      color: light,
      child: ListView(
        children: [
          if(ResponsiveWidget.isSmallScreen(context))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    SizedBox(width: _width / 48),
                    Flexible(
                      child: CustomText(
                        text: "MedIC",
                        size: 20,
                        weight: FontWeight.bold,
                        color: active,
                      ),
                    ),
                    SizedBox(width: _width / 48),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          Divider(color: lightGrey.withOpacity(.1), ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: sideMenuItemRoutes
                .map((item) => SideMenuItem(
                itemName: item.name,
                onTap: () {
                  if(item.route == authenticationPageRoute){
                    Get.offAllNamed(authenticationPageRoute);
                    menuController.changeActiveitemTo(overviewPageDisplayName);

                  }
                  if (!menuController.isActive(item.name)) {
                    menuController.changeActiveitemTo(item.name);
                    if(ResponsiveWidget.isSmallScreen(context))
                      Get.back();
                    navigationController.navigateTo(item.route);
                  }
                }))
                .toList(),
          )
        ],
      ),
    );
  }
}
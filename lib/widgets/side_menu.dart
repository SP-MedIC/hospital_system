import 'package:flutter/material.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:hospital_system/widgets/custom_text.dart';
import 'package:hospital_system/widgets/side_menu_items.dart';
import 'package:get/get.dart';

//display the side menu
class SideMenu extends StatelessWidget {
  const SideMenu({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Container(
      color: light,
      child: ListView(
        children: [
          //menu display setup if the window is in small screen
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

          //create a horizontal lign to visually separate content
          Divider(color: lightGrey.withOpacity(0.1), ),

          //menu display setup when in medium and large screen
          Column(
            mainAxisSize: MainAxisSize.min,
            children: sideMenuItemRoutes
                .map((item) => SideMenuItem(
                itemName: item.name,
                onTap: () {
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
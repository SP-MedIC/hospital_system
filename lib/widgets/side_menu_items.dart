import 'package:flutter/material.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/widgets/horizontal_menu_items.dart';
import 'package:hospital_system/widgets/vertical_menu_items.dart';

//for large screen and medium screen determiner of menu items display
class SideMenuItem extends StatelessWidget {

  final String itemName;
  final VoidCallback onTap;

  const SideMenuItem({Key? key, required this.itemName, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(ResponsiveWidget.isCustomScreen(context))
      //top and bottom setup of menu name
      return VerticalMenuItem(itemName: itemName, onTap: onTap);

      //left and right setup of the menu name
      return HorizontalMenuItem(itemName: itemName, onTap: onTap);
  }
}

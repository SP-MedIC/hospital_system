import 'package:flutter/material.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/widgets/horizontal_menu_items.dart';
import 'package:hospital_system/widgets/vertical_menu_items.dart';

class SideMenuItem extends StatelessWidget {

  final String itemName;
  final VoidCallback onTap;

  const SideMenuItem({Key? key, required this.itemName, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(ResponsiveWidget.isCustomScreen(context))
      return VerticalMenuItem(itemName: itemName, onTap: onTap);

      return HorizontalMenuItem(itemName: itemName, onTap: onTap);
  }
}

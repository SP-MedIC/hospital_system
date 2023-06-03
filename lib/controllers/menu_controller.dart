import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/style.dart';
import 'package:hospital_system/routing/routes.dart';

class CustomMenuController extends GetxController{
  static CustomMenuController instance = Get.find();
  var activeItem = overviewPageDisplayName.obs;
  var hoverItem = "".obs;

  changeActiveitemTo(String itemName){
    activeItem.value = itemName;
  }

  onHover(String itemName){
    if(!isActive(itemName)) hoverItem.value = itemName;
  }

  isActive(String itemName) => activeItem.value == itemName;

  isHovering(String itemName) => hoverItem.value == itemName;

  //Icons to be displayed with the page name
  Widget returnIconFor(String itemName){
    switch(itemName){
      case overviewPageDisplayName:
        return _customIcon(Icons.home_filled, itemName);
      case patientPageDisplayName:
        return _customIcon(Icons.people_alt_outlined, itemName);
      case servicesPageDisplayName:
        return _customIcon(Icons.local_hospital_outlined, itemName);
      case settingsPageDisplayName:
        return _customIcon(Icons.settings, itemName);
      case historyPageDisplayName:
        return _customIcon(Icons.history_outlined, itemName);
      default:
        return _customIcon(Icons.home_filled, itemName);
    }
  }

  Widget _customIcon(IconData icon, String itemName){
    if(isActive(itemName)) return Icon(icon,size: 22, color: darke,);

    return Icon(icon, color: isHovering(itemName) ? darke : lightGrey,);
    
  }
}
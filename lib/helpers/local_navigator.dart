import 'package:flutter/cupertino.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/routing/router.dart';


//Control the navigationController determine which route is associated with which page (stack)
Navigator localNavigator() =>   Navigator(
  key: navigationController.navigatorKey,
  onGenerateRoute: generateRoute,
);


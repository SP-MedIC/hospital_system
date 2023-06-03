import 'package:flutter/cupertino.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/routing/router.dart';
import 'package:hospital_system/routing/routes.dart';

//Initialize the route after logging in
Navigator localNavigator() =>   Navigator(
  key: navigationController.navigatorKey,
  onGenerateRoute: generateRoute,
);


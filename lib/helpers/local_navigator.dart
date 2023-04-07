import 'package:flutter/cupertino.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/routing/router.dart';
import 'package:hospital_system/routing/routes.dart';

Navigator localNavigator() =>   Navigator(
  key: navigationController.navigatorKey,
  initialRoute: overviewPageRoute,
  onGenerateRoute: generateRoute,
);


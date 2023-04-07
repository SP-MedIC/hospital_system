import 'package:flutter/material.dart';
import 'package:hospital_system/pages/authentication/authentication.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:hospital_system/pages/overview/overview.dart';
import 'package:hospital_system/pages/patients/patient_screen.dart';
import 'package:hospital_system/pages/patients/widgets/patient_info.dart';
import 'package:hospital_system/pages/services/servicesPage.dart';
import 'package:hospital_system/pages/settings/settings.dart';
import 'package:hospital_system/routing/routes.dart';
import 'package:path/path.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch (settings.name) {
    case overviewPageRoute:
      return _getPageRoute(OverviewPage());
    case patientPageRoute:
      return _getPageRoute(PatientPage());
    case servicesPageRoute:
      return _getPageRoute(ServicesPage());
    case settingsPageRoute:
      return _getPageRoute(Setting());
    default:
      return _getPageRoute(AuthenticationPage());

  }
}

PageRoute _getPageRoute(Widget child){
  return MaterialPageRoute(
    builder: (context) {
     return child;
    },
  );
}



import 'package:flutter/material.dart';
import 'package:hospital_system/pages/overview/overview.dart';
import 'package:hospital_system/pages/patients/patient_screen.dart';
import 'package:hospital_system/pages/services/servicesPage.dart';
import 'package:hospital_system/pages/settings/settings.dart';
import 'package:hospital_system/routing/routes.dart';

import '../pages/patients/history_screen.dart';

//Function that will handle the page to be returned
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
    case historyPageRoute:
      return _getPageRoute(PreviousPatientScreen());
    default:
      return _getPageRoute(OverviewPage());

  }
}

PageRoute _getPageRoute(Widget child){
  return MaterialPageRoute(
    builder: (context) {
     return child;
    },
  );
}



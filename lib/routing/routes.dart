const rootRoute = "/";

const overviewPageDisplayName = "Overview";
const overviewPageRoute = "/overview";

const patientPageDisplayName = "Hospital Patients";
const patientPageRoute = "/patient_information";

const servicesPageDisplayName = "Hospital Services";
const servicesPageRoute = "/hospital_services";

const settingsPageDisplayName = "Profile Settings";
const settingsPageRoute = "/profile_settings";

const authenticationPageDisplayName = "Log out";
const authenticationPageRoute = "/auth";

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}



List<MenuItem> sideMenuItemRoutes = [
  MenuItem(overviewPageDisplayName, overviewPageRoute),
  MenuItem(patientPageDisplayName, patientPageRoute),
  MenuItem(servicesPageDisplayName, servicesPageRoute),
  MenuItem(settingsPageDisplayName, settingsPageRoute),
];
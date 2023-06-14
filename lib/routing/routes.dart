//route names
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

const historyPageDisplayName = "Previous Patient";
const historyPageRoute = "/history";

const errorPageRoute = "/error";

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}


//List of Menu items to be displayed with name and page route
List<MenuItem> sideMenuItemRoutes = [
  MenuItem(overviewPageDisplayName, overviewPageRoute),
  MenuItem(patientPageDisplayName, patientPageRoute),
  MenuItem(servicesPageDisplayName, servicesPageRoute),
  MenuItem(settingsPageDisplayName, settingsPageRoute),
  MenuItem(historyPageDisplayName, historyPageRoute),
];
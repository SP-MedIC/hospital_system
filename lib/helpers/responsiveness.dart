import 'package:flutter/material.dart';

const int largeScreenSize = 1366;
const int mediumScreenSize = 768;
const int smallScreenSize = 360;
const int customScreenSize = 1100;


//setting up the website screen responsiveness
class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget mediumScreen;
  final Widget smallScreen;


  const ResponsiveWidget({Key? key, required this.largeScreen, required this.mediumScreen, required this.smallScreen}) : super(key: key);

  //use small screen when size less than the medium screen
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < mediumScreenSize;
  }

  //use medium screen when size greater the medium screen but lesser than large screen
  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= mediumScreenSize &&
      MediaQuery.of(context).size.width < largeScreenSize;

  //use medium screen when size greater the medium screen but lesser than large screen
  static bool islargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeScreenSize;

  //Use custom size when size in between medium and before larger screen
  static bool isCustomScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= mediumScreenSize &&
          MediaQuery.of(context).size.width <= customScreenSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints){
      double _width = constraints.maxWidth;

      //iterate between screen sizes
      if(_width >= largeScreenSize){
        return largeScreen;
      }else if(_width < largeScreenSize && _width >= mediumScreenSize){
        return mediumScreen;
      }
      else{
        return smallScreen;
      }


    });
  }
}

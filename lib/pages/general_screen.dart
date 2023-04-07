import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hospital_system/pages/settings/widgets/edit_setting.dart';
import 'package:hospital_system/pages/home_screen.dart';
import 'package:hospital_system/pages/pi_screen.dart';
import 'package:hospital_system/pages/services_screen.dart';
import 'package:hospital_system/pages/settings/settings.dart';
import 'package:hospital_system/pages/authentication/login_page.dart';
import 'package:hospital_system/pages/settings/settings_trial.dart';


class GeneralScreen extends StatefulWidget {
  const GeneralScreen({super.key});

  @override
  _GeneralScreen createState() => _GeneralScreen();
}

class _GeneralScreen extends State<GeneralScreen> {
  int _selectedIndex = 0;

  final _pages = [
    HomeScreen(),
    PIScreen(),
    ServiceScreen(),
    MyForm(),
    //Setting(),
    //Edit_Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text(
            "MedIC"
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          )
        ],
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/img_uppernavbar.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 640?
      BottomNavigationBar(
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.indigoAccent,

          onTap: (int index){
            setState(() {
              _selectedIndex = index;
            });
          },
          items:const[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),label:"Home" ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),label:"Patient Information" ),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital),label:"Services" ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),label:"Settings" ),
          ]
      ):null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 640)
            NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
                //Navigator.of(context).push(
                //  MaterialPageRoute(builder: (context) => _pages[_selectedIndex]),
                //);
              },
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Patient Information'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_hospital),
                  label: Text('Services'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child:_pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
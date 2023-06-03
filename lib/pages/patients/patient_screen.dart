import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/pages/patients/widgets/view_patient_info.dart';
import 'package:hospital_system/pages/patients/widgets/patient_cards_large.dart';
import 'package:hospital_system/pages/patients/widgets/patient_cards_medium.dart';
import 'package:hospital_system/pages/patients/widgets/patient_cards_small.dart';
import 'package:hospital_system/widgets/custom_text.dart';

import '../../constants/style.dart';
import '../../widgets/live_date_time.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({Key? key}) : super(key: key);

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(top:
                ResponsiveWidget.isSmallScreen(context) ? 56 : 6
                ),
                child: CustomText(
                  text: menuController.activeItem.value,
                  size: 24,
                  weight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(child: Container(),),
              Container(
                child: LiveDateTimeScreen(),
              ),
            ],
          ),
        );
        }),
        Expanded(
            child: ListView(
              children: [
                if(ResponsiveWidget.islargeScreen(context) ||
                    ResponsiveWidget.isMediumScreen(context))
                  if(ResponsiveWidget.isCustomScreen(context))
                    OverviewCardsMediumScreen()
                  else
                    OverViewCardsLargeScreen()
                else
                  OverviewCardsSmallScreen(),
                SizedBox(
                  height: 10,
                ),
                ViewPatientInformation(),
              ],
            )
        ),
      ],
    );
  }
}

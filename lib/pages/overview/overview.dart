import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/pages/overview/widgets/requesting_patients.dart';
import 'package:hospital_system/widgets/live_date_time.dart';
import 'package:hospital_system/pages/overview/widgets/overview_cards_large.dart';
import 'package:hospital_system/pages/overview/widgets/overview_cards_medium.dart';
import 'package:hospital_system/pages/overview/widgets/overview_cards_small.dart';
import 'package:hospital_system/widgets/custom_text.dart';

import '../../constants/style.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
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
        //Container(
          //child: LiveDateTimeScreen(),
        //),
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
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        CustomText(
                          text: "Requesting Patients",
                          color: lightGrey,
                          weight: FontWeight.bold,
                        ),
                      ],
                    ),
                    RequestingPatients(),
                  ],
                )
              ],
            )
        ),
      ],
    );
  }
}

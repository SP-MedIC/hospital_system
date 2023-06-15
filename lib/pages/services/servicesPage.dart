import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/pages/services/widgets/services_info.dart';
import 'package:hospital_system/widgets/custom_text.dart';

import '../../widgets/live_date_time.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Padding(
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
        )),
        Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top:50),
                child: ServicesInformation(),
              ),
            )
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_system/constants/controllers.dart';
import 'package:hospital_system/helpers/responsiveness.dart';
import 'package:hospital_system/pages/patients/widgets/hospital_prev_patient.dart';
import 'package:hospital_system/widgets/custom_text.dart';
import '../../widgets/live_date_time.dart';

class PreviousPatientScreen extends StatefulWidget {
  const PreviousPatientScreen({Key? key}) : super(key: key);

  @override
  State<PreviousPatientScreen> createState() => _PreviousPatientScreen();
}

class _PreviousPatientScreen extends State<PreviousPatientScreen> {
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
            child: Container(
              child: PreviousPatient(),
            )
        ),
      ],
    );
  }
}

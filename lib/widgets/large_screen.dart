import 'package:flutter/material.dart';
import 'package:hospital_system/helpers/local_navigator.dart';
import 'package:hospital_system/widgets/side_menu.dart';

class LargeScreen extends StatelessWidget {
  const LargeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SideMenu()
        ),
        Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: localNavigator(),
            )
        ),
      ],
    );
  }
}

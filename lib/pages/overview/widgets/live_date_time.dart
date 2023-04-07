import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveDateTimeScreen extends StatefulWidget {
  const LiveDateTimeScreen({Key? key}) : super(key: key);

  @override
  State<LiveDateTimeScreen> createState() => _LiveDateTimeScreenState();
}

class _LiveDateTimeScreenState extends State<LiveDateTimeScreen> {
  String timeText = "";
  String dateText = "";

  String formatCurrentLiveTime(DateTime time){
    return DateFormat("hh:mm:ss a").format(time);
  }

  String formatCurrentDate(DateTime date){
    return DateFormat("dd MMMM, yyyy").format(date);
  }

  getCurrentLiveTime(){
    final DateTime timeNow = DateTime.now();
    final String liveTime = formatCurrentLiveTime(timeNow);
    final String liveDate = formatCurrentDate(timeNow);

    if(this.mounted){
      setState(() {
        timeText= liveTime;
        dateText= liveDate;
      });
    }
  }

  @override
  void initState(){
    super.initState();

    timeText= formatCurrentLiveTime(DateTime.now());

    dateText= formatCurrentDate(DateTime.now());

    Timer.periodic(const Duration(seconds: 1),(timer){
      getCurrentLiveTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 50,
                      color:Colors.black,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height:6),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 30,
                      color:Colors.black,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

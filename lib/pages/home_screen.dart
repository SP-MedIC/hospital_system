import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
        backgroundColor: Colors.white70,
        body: Column(
          children: [
            Container(
              child: Center(
                child: Column(
                    children:[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
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
                              SizedBox(height:10),
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Text(
                          "Home",
                          style: const TextStyle(
                            fontSize: 30,
                            color:Colors.red,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.resolveWith(
                                          (states) => Colors.red.shade200),
                                  columnSpacing: (MediaQuery.of(context).size.width / 10) * 0.5,
                                  dataRowHeight: 50,
                                  columns: const <DataColumn>[
                                    DataColumn(
                                      label: Text(
                                        'Name',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Age',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Birthdate',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Address',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Triage Result',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Paramedic',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Status',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    DataRow(
                                      cells:<DataCell>[
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('Airan Cruz'))),
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('19'))),
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('February, 4, 1996'))),
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('Miag-ao, Iloilo'))),
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('Emergency'))),
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('Assigned'))),
                                        DataCell(Container(width:(MediaQuery.of(context).size.width/10), child: Text('Incoming'))),
                                      ],
                                    ),
                                    DataRow(
                                      cells:<DataCell>[
                                        DataCell(Text('Airan Cruz')),
                                        DataCell(Text('19')),
                                        DataCell(Text('February, 4, 1996')),
                                        DataCell(Text('Miag-ao, Iloilo')),
                                        DataCell(Text('Emergency')),
                                        DataCell(Text('Assigned')),
                                        DataCell(Text('Incoming')),
                                      ],
                                    ),
                                    DataRow(
                                      cells:<DataCell>[
                                        DataCell(Text('Airan Cruz')),
                                        DataCell(Text('19')),
                                        DataCell(Text('February, 4, 1996')),
                                        DataCell(Text('Miag-ao, Iloilo')),
                                        DataCell(Text('Emergency')),
                                        DataCell(Text('Assigned')),
                                        DataCell(Text('Incoming')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

//Get the nearest ambulance
class AutoGetAmbulance{
  String endLat;
  String endLng;
  AutoGetAmbulance({required this.endLat, required this.endLng});

  //final CollectionReference hospitals = FirebaseFirestore.instance.collection('hospitals');

  final Map<String, dynamic> hospitalMap = {};

  String nearestHospital = "nearest hospital";

  Future computeDistance({
    required String startLatitude,
    required String startLongitude,
    required String endLatitude,
    required String endLongitude,
    required String trafficModel,
    required String departureTime,
  }) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$endLatitude,$endLongitude&origins=$startLatitude,$startLongitude&traffic_model=$trafficModel&departure_time=$departureTime&key=AIzaSyAS8T5voHU_bam5GCQIELBbWirb9bCZZOA';
    //String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$destination&origins=$origin&&traffic_model=$trafficModel&departure_time=$departureTime&key=AIzaSyAS8T5voHU_bam5GCQIELBbWirb9bCZZOA';

    try {
      var response = await Dio().get(url);
      print(response.data);
      if (response.statusCode == 200) {
        //print(response.data);
        for (var row in response.data['rows']) {
          for (var element in row['elements']) {
            //print(element['duration_in_traffic']['value']);
            return (element['duration_in_traffic']['value']);
          }
        }
      }
      else {
        print(startLatitude);
        return;
      }
    }
    catch (e) {
      print(e);
    }
  }


  Future<Map<String, dynamic>> main() async {
    var data = await FirebaseFirestore.instance.collection('users')
        .where("Role", isEqualTo: "Paramedic")
        .where('availability', isEqualTo: 'Online')
        .where('status', isEqualTo: 'Unassigned').get();

    for (var document in data.docs) {
      Map<String, dynamic> data = document.data();

      print(data['Full Name']);

      var timeTravel = await computeDistance(
        startLatitude: data['Location']['latitude'].toString(),
        startLongitude: data['Location']['longitude'].toString(),
        endLatitude: endLat,
        endLongitude: endLng,
        trafficModel: 'best_guess', //integrates live traffic information
        departureTime: 'now',
      );
      //print(timeTravel);
      //print(timeTravel.runtimeType);


      hospitalMap.addAll({document.id: timeTravel});
    }
    print(hospitalMap);
    // var nearest = hospitalMap.values.cast<num>().reduce(min);
    //
    // hospitalMap.forEach((key, value) {
    //   if (value == nearest) {
    //     nearestHospital = key;
    //   }
    // });
    // //print(hospitalMap);
    // print(nearestHospital);
    return hospitalMap;
  }

}


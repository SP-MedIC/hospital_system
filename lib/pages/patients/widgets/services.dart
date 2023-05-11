import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalService {
  Future<List<String>> getListService() async {
    final listServices = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final service = listServices['use_services'] as Map<String, dynamic>;
    final serviceNames = service.keys.toList();
    return List<String>.from(serviceNames);
  }
}

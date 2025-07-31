import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getRealTimeMachineData(String machineName) {
    return _firestore.collection('test').doc(machineName).snapshots();
  }

Future<void> updateMachineStat(String machineName, String status) async {
  await FirebaseFirestore.instance
      .collection('test')
      .doc(machineName)
      .update({'status': status});
}

}

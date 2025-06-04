import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TeacherProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Teacher Profile
  Future<Map<String, dynamic>?> getTeacherProfile(String employeeId) async {
    try {
      final doc = await _firestore.collection('teachers').doc(employeeId).get();

      if (!doc.exists) {
        throw 'Teacher with employee ID $employeeId not found';
      }
      print('Fetched Teacher Profile: ${doc.data()}');
      return doc.data();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching teacher profile: $e');
      return null;
    }
  }
}

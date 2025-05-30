import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final userType = await AuthService.getUserType();
      if (userType != 'admin' && userType != 'teacher') {
        throw 'Unauthorized: Only admins or teachers can access student details.';
      }

      final querySnapshot = await _firestore.collection('students').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}

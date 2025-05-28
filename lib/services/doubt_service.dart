import 'package:cloud_firestore/cloud_firestore.dart';

class DoubtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save a new doubt to Firestore
  Future<void> saveDoubt({
    required String studentRollNumber,
    required String message,
    String? imageUrl,
    required String response,
    required DateTime timestamp,
  }) async {
    try {
      await _firestore
          .collection('students')
          .doc(studentRollNumber)
          .collection('doubts')
          .add({
        'message': message,
        'imageUrl': imageUrl,
        'response': response,
        'timestamp': timestamp,
        'isResolved': false,
      });
    } catch (e) {
      throw Exception('Failed to save doubt: $e');
    }
  }

  // Get all doubts for a student
  Stream<QuerySnapshot> getStudentDoubts(String studentRollNumber) {
    return _firestore
        .collection('students')
        .doc(studentRollNumber)
        .collection('doubts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark a doubt as resolved
  Future<void> markDoubtAsResolved(
      String studentRollNumber, String doubtId) async {
    try {
      await _firestore
          .collection('students')
          .doc(studentRollNumber)
          .collection('doubts')
          .doc(doubtId)
          .update({'isResolved': true});
    } catch (e) {
      throw Exception('Failed to update doubt status: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getStudentsByClass(
      String className, String? section) async {
    try {
      // Start with base query for class
      Query query = _firestore
          .collection('students')
          .where('class', isEqualTo: className);

      // Add section filter only if provided and non-empty
      if (section != null && section.isNotEmpty) {
        query = query.where('section', isEqualTo: section);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching students: $e');
      // Return empty list on error (or rethrow based on your error handling strategy)
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final snapshot = await _firestore.collection('students').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching all students: $e');
      return [];
    }
  }
}

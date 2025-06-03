import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch student profile details
  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || userType != 'student') {
        throw 'No logged-in student found.';
      }

      final doc = await _firestore.collection('students').doc(userId).get();

      if (!doc.exists) {
        throw 'Student profile not found.';
      }

      return doc.data()!;
    } catch (e) {
      rethrow;
    }
  }
}

class EditProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch student profile details
  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || userType != 'student') {
        throw 'No logged-in student found.';
      }

      final doc = await _firestore.collection('students').doc(userId).get();

      if (!doc.exists) {
        throw 'Student profile not found.';
      }

      return doc.data()!;
    } catch (e) {
      rethrow;
    }
  }

  // Update student profile details
  Future<void> updateStudentProfile({
    required String fullName,
    required String studentClass,
    required String section,
    required String parentEmail,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || userType != 'student') {
        throw 'No logged-in student found.';
      }

      await _firestore.collection('students').doc(userId).set({
        'fullName': fullName.trim(),
        'class': studentClass.trim(),
        'section': section.trim(),
        'parentEmail': parentEmail.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
}

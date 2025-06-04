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

  // Fetch student profile by userId
  Future<Map<String, dynamic>> getStudentProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('students').doc(userId).get();
      if (!doc.exists) {
        throw 'Student profile not found.';
      }
      return doc.data()!;
    } catch (e) {
      rethrow;
    }
  }

  // Get children associated with a parent
  Future<List<Map<String, dynamic>>> getParentChildren(String parentId) async {
    try {
      if (parentId.isEmpty) {
        print('Parent ID is empty');
        return [];
      }

      final snapshot = await _firestore
          .collection('students')
          .where('parentId', isEqualTo: parentId)
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('No children found for parent: $parentId');
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id; // Add the document ID as userId
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching parent children: $e');
      return [];
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

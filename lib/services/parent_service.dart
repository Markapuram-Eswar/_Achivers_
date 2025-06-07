import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ParentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getParentProfile() async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || userType != 'parent') {
        throw 'Unauthorized: Only parents can access this profile.';
      }

      // Fetch parent document
      final parentDoc =
          await _firestore.collection('parents').doc(userId).get();
      if (!parentDoc.exists) {
        throw 'Parent profile not found.';
      }

      final parentData = parentDoc.data()!;
      final List<String> childRollNumbers =
          List<String>.from(parentData['children'] ?? []);

      // Fetch child details
      final childrenDetails = <Map<String, dynamic>>[];

      for (final rollNumber in childRollNumbers) {
        final childDoc =
            await _firestore.collection('students').doc(rollNumber).get();
        if (childDoc.exists) {
          final childData = childDoc.data()!;
          childData['id'] = childDoc.id;
          childrenDetails.add(childData);
        }
      }

      return {
        'parentId': parentData['parentId'],
        'name': parentData['name'],
        'phone': parentData['phone'],
        'email': parentData['email'],
        'address': parentData['address'],
        'children': childrenDetails,
        'createdAt': parentData['createdAt'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getStudentAttendance(String rollNumber) async {
    try {
      final attendanceDoc = await _firestore
          .collection('students')
          .doc(rollNumber)
          .collection('attendance')
          .doc('current')
          .get();

      if (!attendanceDoc.exists) {
        return {
          'totalDays': 0,
          'presentDays': 0,
          'percentage': 0.0,
        };
      }

      final data = attendanceDoc.data()!;
      final totalDays = data['totalDays'] ?? 0;
      final presentDays = data['presentDays'] ?? 0;
      final percentage = totalDays > 0 ? (presentDays * 100 / totalDays) : 0.0;

      return {
        'totalDays': totalDays,
        'presentDays': presentDays,
        'percentage': percentage,
      };
    } catch (e) {
      print('Error fetching attendance: $e');
      return {
        'totalDays': 0,
        'presentDays': 0,
        'percentage': 0.0,
      };
    }
  }

  Future<Map<String, dynamic>> _getStudentGrades(String rollNumber) async {
    try {
      // Fetch grade assessments
      final gradeAssessmentsSnapshot = await _firestore
          .collection('students')
          .doc(rollNumber)
          .collection('gradeAssessments')
          .get();

      // Fetch test zones
      final testZonesSnapshot = await _firestore
          .collection('students')
          .doc(rollNumber)
          .collection('testZones')
          .get();

      double totalScore = 0;
      int totalItems = 0;

      // Process grade assessments
      for (var doc in gradeAssessmentsSnapshot.docs) {
        final data = doc.data();
        if (data['score'] != null) {
          totalScore += data['score'];
          totalItems++;
        }
      }

      // Process test zones
      for (var doc in testZonesSnapshot.docs) {
        final data = doc.data();
        if (data['score'] != null) {
          totalScore += data['score'];
          totalItems++;
        }
      }

      final averageScore = totalItems > 0 ? totalScore / totalItems : 0;
      final grade = _calculateGrade(averageScore.toDouble());

      return {
        'averageScore': averageScore,
        'grade': grade,
        'totalAssessments': totalItems,
      };
    } catch (e) {
      print('Error fetching grades: $e');
      return {
        'averageScore': 0,
        'grade': 'N/A',
        'totalAssessments': 0,
      };
    }
  }

  String _calculateGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    if (score >= 50) return 'E';
    return 'F';
  }

  Future<Map<String, dynamic>> updateParentProfile({
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      print(
          'updateParentProfile called with email: $email, phone: $phone, address: $address');
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || userType != 'parent') {
        throw Exception('Unauthorized: Only parents can update this profile');
      }

      final parentDoc =
          await _firestore.collection('parents').doc(userId).get();
      if (!parentDoc.exists) {
        throw Exception('Parent profile not found');
      }

      await _firestore.collection('parents').doc(userId).update({
        'email': email,
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return the updated profile data
      final updatedDoc =
          await _firestore.collection('parents').doc(userId).get();
      return updatedDoc.data()!;
    } catch (e) {
      print('Error updating parent profile: $e');
      rethrow;
    }
  }
}

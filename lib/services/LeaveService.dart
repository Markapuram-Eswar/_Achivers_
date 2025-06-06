import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'ProfileService.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> applyLeaveForChild({
    required String childRollNumber, // Changed from childId to childRollNumber
    required String leaveType,
    required String reason,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || userType != 'parent') {
        throw 'Unauthorized: Only parents can apply leave for children.';
      }

      // Fetch student profile using roll number
      final studentProfile =
          await ProfileService().getStudentProfileById(childRollNumber);
      if (studentProfile == null) {
        throw 'Student with roll number $childRollNumber not found';
      }

      final leaveData = {
        'childId':
            studentProfile['userId'], // Use the userId from student profile
        'childRollNumber': childRollNumber,
        'class': studentProfile['class'],
        'section': studentProfile['section'],
        'classTeacherId': studentProfile['classTeacherId'],
        'leaveType': leaveType,
        'reason': reason,
        'fromDate': Timestamp.fromDate(fromDate),
        'toDate': Timestamp.fromDate(toDate),
        'appliedBy': userId,
        'appliedAt': Timestamp.now(),
        'status': 'pending',
      };

      await _firestore.collection('leave_applications').add(leaveData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLeavesForClassTeacher(
      String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection('leave_applications')
          .where('classTeacherId', isEqualTo: employeeId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching leaves for teacher: $e');
      return [];
    }
  }
}

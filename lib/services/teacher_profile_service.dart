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

  // Update Teacher's Class and Section (legacy, for single class/section)
  Future<void> updateTeacherClassSection({
    required String teacherId,
    required String className,
    required String section,
  }) async {
    try {
      await _firestore.collection('teachers').doc(teacherId).update({
        'class': className,
        'section': section,
      });
      Fluttertoast.showToast(msg: 'Class and section updated successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error updating class/section: $e');
      rethrow;
    }
  }

  // Add a class/section to the teacher's classes list
  Future<void> addTeacherClass({
    required String teacherId,
    required String className,
    required String section,
  }) async {
    try {
      await _firestore.collection('teachers').doc(teacherId).update({
        'classes': FieldValue.arrayUnion([
          {'class': className, 'section': section}
        ])
      });
      Fluttertoast.showToast(msg: 'Class added successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error adding class: $e');
      rethrow;
    }
  }

  // Remove a class/section from the teacher's classes list
  Future<void> removeTeacherClass({
    required String teacherId,
    required String className,
    required String section,
  }) async {
    try {
      await _firestore.collection('teachers').doc(teacherId).update({
        'classes': FieldValue.arrayRemove([
          {'class': className, 'section': section}
        ])
      });
      Fluttertoast.showToast(msg: 'Class removed successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error removing class: $e');
      rethrow;
    }
  }
}

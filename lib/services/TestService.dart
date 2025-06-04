import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new test
  Future<void> createTest({
    required String subject,
    required String classLevel,
    required String section,
    required DateTime date,
    required String time,
    required int duration,
    required int maxMarks,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || (userType != 'teacher' && userType != 'admin')) {
        throw 'Unauthorized: Only teachers or admins can create tests.';
      }

      // Step 1: Add the test
      final testDocRef = await _firestore.collection('tests').add({
        'subject': subject.trim(),
        'class': classLevel.trim(),
        'section': section.trim(),
        'date': Timestamp.fromDate(date),
        'time': time.trim(),
        'duration': duration,
        'maxMarks': maxMarks,
        'questions': questions,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final testId = testDocRef.id;

      // Step 2: Fetch matching students
      final studentsSnapshot = await _firestore
          .collection('students')
          .where('class', isEqualTo: classLevel)
          .where('section', isEqualTo: section)
          .get();

      // Step 3: Update each student doc with the test info
      for (var doc in studentsSnapshot.docs) {
        final studentRef = doc.reference;

        await studentRef.update({
          'tests': FieldValue.arrayUnion([
            {
              'testId': testId,
              'subject': subject.trim(),
              'testName': '$subject Test',
              'status': 'pending',
              // 'dateAssigned': FieldValue.serverTimestamp(),
            }
          ])
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all tests created by current user (optional, for listing)
  Future<List<Map<String, dynamic>>> getMyTests() async {
    try {
      final userId = await AuthService.getUserId();
      final userType = await AuthService.getUserType();

      if (userId == null || (userType != 'teacher' && userType != 'admin')) {
        throw 'Unauthorized: Only teachers or admins can view their tests.';
      }

      final snapshot = await _firestore
          .collection('tests')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentTests() async {
    final userId = await AuthService.getUserId();
    final userType = await AuthService.getUserType();

    if (userId == null || userType != 'student') {
      throw 'Unauthorized: Only students can fetch their tests.';
    }

    // Get the student's class and section
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null ||
        !userData.containsKey('class') ||
        !userData.containsKey('section')) {
      throw 'User data is incomplete.';
    }

    final classLevel = userData['class'];
    final section = userData['section'];

    // Fetch tests matching class and section
    final querySnapshot = await _firestore
        .collection('tests')
        .where('class', isEqualTo: classLevel)
        .where('section', isEqualTo: section)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTestsForClassAndSection() async {
    final userId = await AuthService.getUserId();
    final userType = await AuthService.getUserType();

    if (userId == null || userType != 'student') {
      throw 'Unauthorized: Only students can fetch profile tests.';
    }

    final userDoc = await _firestore.collection('students').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null || !userData.containsKey('tests')) {
      return []; // No tests assigned
    }

    final List<dynamic> rawTests = userData['tests'];
    return rawTests
        .map<Map<String, dynamic>>((test) => Map<String, dynamic>.from(test))
        .toList();
  }
}

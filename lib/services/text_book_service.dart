import 'package:cloud_firestore/cloud_firestore.dart';

class TextBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch textbook content for a given school, grade, subject, and topic
  Future<Map<String, dynamic>?> getTextbookContent({
    required String school,
    required String grade,
    required String subject,
    required String topic,
  }) async {
    try {
      // Reference to the textbooks collection and the specific school document
      DocumentSnapshot schoolDoc =
          await _firestore.collection('textbooks').doc(school).get();

      if (!schoolDoc.exists) {
        print('School document not found.');
        return null;
      }

      final data = schoolDoc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Traverse to the grade map
      final gradeMap = data[grade] as Map<String, dynamic>?;
      if (gradeMap == null) return null;

      // Traverse to the subject map
      final subjectMap = gradeMap[subject] as Map<String, dynamic>?;
      if (subjectMap == null) return null;

      // Get the topic content
      final topicContent = subjectMap[topic];
      if (topicContent == null) return null;

      // If topicContent is a map, return it directly
      if (topicContent is Map<String, dynamic>) {
        return topicContent;
      }
      // If it's not a map, wrap it in a map
      return {'content': topicContent};
    } catch (e) {
      print('Error fetching textbook content: $e');
      return null;
    }
  }
}

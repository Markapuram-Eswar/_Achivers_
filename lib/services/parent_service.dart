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
        'children': childrenDetails,
        'createdAt': parentData['createdAt'],
      };
    } catch (e) {
      rethrow;
    }
  }
}

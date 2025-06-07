import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches subjects for a specific grade in a school
  Future<Map<String, dynamic>> fetchSubjects(String schoolName, String grade) async {
    try {
      // Reference to the "practice" collection and the specific school document
      DocumentSnapshot schoolDoc = await _firestore
          .collection('practice')
          .doc(schoolName)
          .get();

      if (schoolDoc.exists) {
        // Get data for the specific grade
        Map<String, dynamic>? schoolData = schoolDoc.data() as Map<String, dynamic>?;
        return schoolData?[grade] ?? {};
      } else {
        print("School document not found.");
        return {};
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchTopics(String schoolName, String grade, String subject) async {
    try {
      // Reference to the "practice" collection and the specific school document
      DocumentSnapshot schoolDoc = await _firestore
          .collection('practice')
          .doc(schoolName)
          .get();

      if (schoolDoc.exists) {
        // Get data for the specific grade
        Map<String, dynamic>? schoolData = schoolDoc.data() as Map<String, dynamic>?;
        Map<String, dynamic>? gradeData = schoolData?[grade] as Map<String, dynamic>?;
        return gradeData?[subject] ?? {};
      } else {
        print("School document not found.");
        return {};
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      return {};
    }
  }
}


// class PracticeZoneService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//   // Fetch all schools
//   Future<List<String>> fetchAllSchools() async {
//     try {
//     //   final snapshot = await _firestore.collection('PracticeZone').doc('School').collectionGroup('').get();
//       // Firestore doesn't support collectionGroup(''), so instead:
//       final schoolsSnapshot = await _firestore.collection('PracticeZone').doc('School').get();  
//       return schoolsSnapshot.data()?.keys.cast<String>().toList() ?? [];
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error fetching schools: $e');
//       return [];
//     }
//   }

//   // Fetch all grades for a school
//   Future<List<String>> fetchGrades(String schoolName) async {
//     try {
//       final gradesSnapshot = await _firestore
//           .collection('PracticeZone')
//           .doc('School')
//           .collection(schoolName)
//           .get();
//       return gradesSnapshot.docs.map((doc) => doc.id).toList();
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error fetching grades: $e');
//       return [];
//     }
//   }

  // Fetch subjects for a school and grade
//   Future<Map<String, dynamic>?> fetchSubjects(String schoolName, String grade) async {
//     try {
//       final doc = await _firestore
//           .collection('PracticeZone')
//           .doc('School')
//           .collection(schoolName)
//           .doc(grade)
//           .get();
//       if (!doc.exists) {
//         Fluttertoast.showToast(msg: 'No data found for $schoolName in grade $grade.');
//         return null;
//       }
//       return doc.data();
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error fetching subjects: $e');
//       return null;
//     }
//   }
// }
// Future<Map<String, dynamic>?> fetchSubjects(String schoolName) async {
//   try {
//     print('Fetching subjects for: $schoolName');
    
//     final doc = await _firestore
//         .collection('PracticeZone')
//         .doc(schoolName).get();

//     if (!doc.exists) {
//       print('❌ Document not found at path: PracticeZone/School/$schoolName');
//       Fluttertoast.showToast(msg: 'No data found for $schoolName.');
//       return null;
//     }

//     final data = doc.data();
//     print('✅ Retrieved document data: $data');
    
//     if (data == null || data.isEmpty) {
//       print('❌ Document exists but has no data');
//       return null;
//     }
    
//     // Since the document IS the subjects map, return it directly
//     return Map<String, dynamic>.from(data);
//   } catch (e) {
//     print('❌ Error fetching subjects: $e');
//     Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
//     return null;
//   }
// }

// }


// import 'package:firebase_database/firebase_database.dart';

// class FirebaseSubjectService {
//   final DatabaseReference _databaseReference =
//       FirebaseFirestore.instance.collection("PracticeZone/School");

//   /// Fetch all subjects for a specific school and grade.
//   Future<Map<String, dynamic>?> fetchSubjects(String schoolName, String grade) async {
//     try {
//       // Construct the Firebase path for the requested school and grade.
//       DatabaseEvent event = await _databaseReference.child("$schoolName/$grade").once();

//       if (event.snapshot.exists) {
//         // Return the retrieved data as a Map.
//         return Map<String, dynamic>.from(event.snapshot.value as Map);
//       } else {
//         print("No data found for $schoolName in grade $grade.");
//         return null;
//       }
//     } catch (e) {
//       // Handle any errors during the fetch operation.
//       print("Error while fetching subjects: $e");
//       return null;
//     }
//   }

//   /// Fetch all schools available in the database.
//   Future<List<String>> fetchAllSchools() async {
//     try {
//       DatabaseEvent event = await _databaseReference.once();

//       if (event.snapshot.exists) {
//         return (event.snapshot.value as Map).keys.cast<String>().toList();
//       } else {
//         print("No schools found in the database.");
//         return [];
//       }
//     } catch (e) {
//       print("Error while fetching schools: $e");
//       return [];
//     }
//   }

//   /// Fetch all grades for a specific school.
//   Future<List<String>> fetchGrades(String schoolName) async {
//     try {
//       DatabaseEvent event = await _databaseReference.child(schoolName).once();

//       if (event.snapshot.exists) {
//         return (event.snapshot.value as Map).keys.cast<String>().toList();
//       } else {
//         print("No grades found for school $schoolName.");
//         return [];
//       }
//     } catch (e) {
//       print("Error while fetching grades: $e");
//       return [];
//     }
//   }
// }

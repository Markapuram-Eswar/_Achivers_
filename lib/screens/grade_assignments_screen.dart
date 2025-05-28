import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home:
        ClassAssignmentsScreen(), // Changed entry point to class selection screen
  ));
}

// New screen to select class and assignment
class ClassAssignmentsScreen extends StatelessWidget {
  const ClassAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - in a real app, this would come from a database
    final classes = [
      {
        'name': 'Class 10-A',
        'assignments': [
          {'title': 'Mathematics Assignment 1', 'due': 'May 15, 2024'},
          {'title': 'Mathematics Quiz 2', 'due': 'May 20, 2024'},
        ],
      },
      {
        'name': 'Class 9-B',
        'assignments': [
          {'title': 'Science Project', 'due': 'May 18, 2024'},
          {'title': 'Physics Lab Report', 'due': 'May 25, 2024'},
        ],
      },
      {
        'name': 'Class 11-C',
        'assignments': [
          {'title': 'History Essay', 'due': 'May 10, 2024'},
          {'title': 'Literature Review', 'due': 'May 22, 2024'},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        title: const Text(
          'Grade Assignments',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(
                      Icons.class_,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Select Class & Assignment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose a class and assignment to grade student submissions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Classes list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Your Classes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          // Expandable class list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, classIndex) {
                final classData = classes[classIndex];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: Text(
                        (classData['name'] as String)[0],
                        style: TextStyle(
                            color: Colors.indigo[700],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      classData['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${(classData['assignments'] as List).length} assignments',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (classData['assignments'] as List).length,
                        itemBuilder: (context, assignmentIndex) {
                          final assignment = (classData['assignments']
                              as List)[assignmentIndex];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 4),
                            leading: Icon(
                              Icons.assignment,
                              color: Colors.indigo[400],
                            ),
                            title: Text(
                              assignment['title']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              'Due: ${assignment['due']}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Navigate to the grading screen with assignment details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GradeAssignmentsScreen(
                                    className: classData['name'] as String,
                                    assignmentTitle: assignment['title']!,
                                    dueDate: assignment['due']!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Modified existing screen to accept parameters
class GradeAssignmentsScreen extends StatefulWidget {
  final String className;
  final String assignmentTitle;
  final String dueDate;

  const GradeAssignmentsScreen({
    super.key,
    required this.className,
    required this.assignmentTitle,
    required this.dueDate,
  });

  @override
  State<GradeAssignmentsScreen> createState() => _GradeAssignmentsScreenState();
}

class _GradeAssignmentsScreenState extends State<GradeAssignmentsScreen> {
  final Map<String, String> _grades = {
    'Eswar Kumar': '',
    'Aditi Sharma': '',
    'Arjun Patel': '',
    'Diya Singh': '',
    'Krishna Rao': '',
    'Ishaan Reddy': '',
    'Kavya Gupta': '',
    'Meera Verma': '',
    'Nikhil Menon': '',
    'Priya Malhotra': '',
  };

  // Track which students have been graded
  final Map<String, bool> _isGraded = {};

  // Track if a grade is valid (0-100)
  final Map<String, bool> _isValidGrade = {};

  @override
  void initState() {
    super.initState();
    /* Backend TODO: Fetch assignments to grade from backend (API call, database read) */
    // Initialize tracking maps
    for (var name in _grades.keys) {
      _isGraded[name] = false;
      _isValidGrade[name] = true;
    }
  }

  // Validate grade is between 0-100
  bool _validateGrade(String value) {
    if (value.isEmpty) return true;
    final grade = int.tryParse(value);
    return grade != null && grade >= 0 && grade <= 100;
  }

  // Calculate class average from valid grades
  String _calculateAverage() {
    final validGrades = _grades.values
        .where((grade) => grade.isNotEmpty && int.tryParse(grade) != null)
        .map((grade) => int.parse(grade))
        .toList();

    if (validGrades.isEmpty) return 'N/A';

    final average = validGrades.reduce((a, b) => a + b) / validGrades.length;
    return average.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final gradedCount = _isGraded.values.where((isGraded) => isGraded).length;
    final totalStudents = _grades.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        title: Text(
          widget.className,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Assignment Info Card
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.assignment,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.assignmentTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _infoCard(
                        'Due Date',
                        widget.dueDate,
                        Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _infoCard(
                        'Class Average',
                        _calculateAverage(),
                        Icons.bar_chart,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _infoCard(
                        'Progress',
                        '$gradedCount/$totalStudents',
                        Icons.people,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Student List Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Student Submissions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Graded: $gradedCount/$totalStudents',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final name = _grades.keys.elementAt(index);
                final grade = _grades[name]!;
                final isGraded = grade.isNotEmpty;
                final isValid = _isValidGrade[name] ?? true;

                if (isGraded) {
                  _isGraded[name] = true;
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isGraded
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Student Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              isGraded ? Colors.green[100] : Colors.grey[200],
                          child: Text(
                            name[0],
                            style: TextStyle(
                              color: isGraded
                                  ? Colors.green[700]
                                  : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Student Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isGraded
                                    ? 'Graded: $grade/100'
                                    : 'Not graded yet',
                                style: TextStyle(
                                  color: isGraded
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Grade Input
                        Container(
                          constraints:
                              const BoxConstraints(minWidth: 60, maxWidth: 80),
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0-100',
                              errorText: !isValid ? 'Invalid' : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      isValid ? Colors.grey[300]! : Colors.red,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isGraded
                                      ? Colors.green
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.indigo[700]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            controller: TextEditingController(text: grade),
                            onChanged: (value) {
                              setState(() {
                                _grades[name] = value;
                                _isValidGrade[name] = _validateGrade(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Save Grades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // Check if all grades are valid
                  final allValid =
                      _isValidGrade.values.every((isValid) => isValid);

                  if (!allValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please correct invalid grades (0-100)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grades saved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create info cards with overflow protection
  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatelessWidget {
  final String className;
  final String section;
  final List<Map<String, String>> students;

  const StudentDetailsScreen({
    super.key,
    required this.className,
    required this.section,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$className - Section $section'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  student['name']!.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                student['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Roll No: ${student['rollNumber']}'),
                  Text('Parent: ${student['parentName']}'),
                  Text('Contact: ${student['contact']}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to individual student details if needed
              },
            ),
          );
        },
      ),
    );
  }
}

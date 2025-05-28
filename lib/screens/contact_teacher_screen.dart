import 'package:flutter/material.dart';

class ContactTeacherScreen extends StatelessWidget {
  const ContactTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> teachers = [
      {
        'name': 'Mrs. Lakshmi',
        'subject': 'Mathematics',
        'image': 'L',
      },
      {
        'name': 'Mr. Ravi Kumar',
        'subject': 'Science',
        'image': 'R',
      },
      {
        'name': 'Mrs. Priya Sharma',
        'subject': 'English',
        'image': 'P',
      },
      {
        'name': 'Mr. Suresh Reddy',
        'subject': 'Social Studies',
        'image': 'S',
      },
      {
        'name': 'Mrs. Anjali Gupta',
        'subject': 'Hindi',
        'image': 'A',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Contact Teachers',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 30,
                child: Text(
                  teacher['image']!,
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(
                teacher['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(teacher['subject']!),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildContactButton(
                        icon: Icons.message,
                        label: 'Message',
                        onPressed: () {
                          /* Backend TODO: Send message to teacher via backend (API call, database write) */
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Sending message to [1m${teacher['name']}...'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildContactButton(
                        icon: Icons.connect_without_contact,
                        label: 'Connect',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Connecting with ${teacher['name']}...'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

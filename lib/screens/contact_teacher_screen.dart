import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactTeacherScreen extends StatelessWidget {
  const ContactTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> teachers = [
      {
        'name': 'Mrs. Lakshmi',
        'subject': 'Mathematics',
        'image': 'L',
        'phone': '+911234567890', // Add phone numbers for WhatsApp
      },
      {
        'name': 'Mr. Ravi Kumar',
        'subject': 'Science',
        'image': 'R',
        'phone': '+911234567891',
      },
      {
        'name': 'Mrs. Priya Sharma',
        'subject': 'English',
        'image': 'P',
        'phone': '+911234567892',
      },
      {
        'name': 'Mr. Suresh Reddy',
        'subject': 'Social Studies',
        'image': 'S',
        'phone': '+911234567893',
      },
      {
        'name': 'Mrs. Anjali Gupta',
        'subject': 'Hindi',
        'image': 'A',
        'phone': '+911234567894',
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
                        icon: Icons.connect_without_contact,
                        label: 'WhatsApp',
                        onPressed: () async {
                          final phoneNumber = teacher['phone']!;
                          final message =
                              'Hello ${teacher['name']}, I would like to connect with you regarding ${teacher['subject']}.';
                          final whatsappUrl =
                              'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

                          if (await canLaunchUrlString(whatsappUrl)) {
                            await launchUrlString(whatsappUrl);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch WhatsApp'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ContactTeacherScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ContactTeacherScreen extends StatelessWidget {
  final bool showExitConfirmation;
  final Widget? previousScreen;
  final bool isFromHomePage;

  const ContactTeacherScreen({
    super.key,
    this.showExitConfirmation = false,
    this.previousScreen,
    this.isFromHomePage = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> teachers = [
      {
        'name': 'Mr. test',
        'subject': 'Mathematics',
        'image': 'L',
        'phone': '918106645476', // Add phone numbers for WhatsApp
      },
      {
        'name': 'Mr.anirudd ',
        'subject': 'Science',
        'image': 'R',
        'phone': '917032933445',
      },
      {
        'name': 'Mrs. Priya Sharma',
        'subject': 'English',
        'image': 'P',
        'phone': '911234567892',
      },
      {
        'name': 'Mr. Suresh Reddy',
        'subject': 'Social Studies',
        'image': 'S',
        'phone': '911234567893',
      },
      {
        'name': 'Mrs. Anjali Gupta',
        'subject': 'Hindi',
        'image': 'A',
        'phone': '911234567894',
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        if (isFromHomePage) {
          // Show exit confirmation when coming from home page
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App?'),
              content: const Text('Do you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        } else if (previousScreen != null) {
          // Navigate back to previous screen (parent dashboard)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => previousScreen!),
          );
          return false; // Prevent default back behavior
        }
        return true; // Default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: !isFromHomePage,
          backgroundColor: Colors.blue[900],
          title: const Text(
            'Contact Teachers',
            style: TextStyle(color: Colors.white),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildContactButton(
                        icon: Icons.connect_without_contact,
                        label: 'WhatsApp',
                        backgroundColor: const Color(0xFF25D366),
                        onPressed: () async {
                          String phoneNumber = teacher['phone']!;
                          if (phoneNumber.startsWith('+')) {
                            phoneNumber = phoneNumber.substring(1);
                          }
                          final message =
                              'Hello ${teacher['name']}, I would like to connect with you regarding ${teacher['subject']}.';
                          final whatsappUrl =
                              'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
                          await launchUrlString(
                            whatsappUrl,
                            mode: LaunchMode.externalApplication,
                          );
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
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return ElevatedButton.icon(
      icon: FaIcon(FontAwesomeIcons.whatsapp,
          size: 26, color: Colors.white), // WhatsApp icon
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600], // WhatsApp green
        foregroundColor: Colors.white,
        minimumSize: const Size(140, 52),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
      ),
    );
  }
}

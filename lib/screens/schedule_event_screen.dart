import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/AssessmentService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    const MaterialApp(
      home: SendMessageScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedClass;
  String? _selectedSection;
  List<String> _selectedStudents = [];
  String _recipientType = 'Both';

  final List<String> _classes =
      List.generate(12, (index) => 'Class ${index + 1}');
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  // FCM Server Key - Replace with your actual server key
  static const String _serverKey = 'AIzaSyA-orrxPFEHb6FRg7yUHyCcLZiJkXjgchU';

  // Function to get FCM tokens for selected recipients
  Future<List<String>> _getRecipientTokens() async {
    Set<String> tokens = {}; // Use Set to avoid duplicates

    try {
      // 1. Fetch students based on filters
      Query query = FirebaseFirestore.instance.collection('students');
      if (_selectedClass != null) {
        query = query.where('class', isEqualTo: _selectedClass);
      }
      if (_selectedSection != null) {
        query = query.where('section', isEqualTo: _selectedSection);
      }

      QuerySnapshot studentSnapshot = await query.get();

      for (QueryDocumentSnapshot studentDoc in studentSnapshot.docs) {
        final studentData = studentDoc.data() as Map<String, dynamic>;

        // Identifier to match selected student
        final rollNumber = studentData['rollNumber']?.toString() ?? '';
        final name = studentData['name']?.toString() ?? '';
        final identifier = rollNumber.isNotEmpty ? rollNumber : name;

        if (_selectedStudents.contains(identifier)) {
          // Add Student FCM Token
          if (_recipientType == 'Only Students' || _recipientType == 'Both') {
            final studentToken = studentData['studentFCMToken']?.toString();
            if (studentToken != null && studentToken.isNotEmpty) {
              tokens.add(studentToken);
            }
          }

          // Add Parent FCM Token from parents collection
          if (_recipientType == 'Only Parents' || _recipientType == 'Both') {
            final parentId = studentData['parentId']?.toString();
            if (parentId != null && parentId.isNotEmpty) {
              final parentDoc = await FirebaseFirestore.instance
                  .collection('parents')
                  .doc(parentId)
                  .get();

              if (parentDoc.exists) {
                final parentData = parentDoc.data() as Map<String, dynamic>;
                final parentToken = parentData['parentFCMToken']?.toString();
                if (parentToken != null && parentToken.isNotEmpty) {
                  tokens.add(parentToken);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error getting recipient tokens: $e');
    }

    return tokens.toList();
  }

  // Function to send FCM notification
  Future<void> _sendFCMNotification(
      List<String> tokens, String title, String body) async {
    if (tokens.isEmpty) return;

    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'title': title,
      'body': body,
      'sound': 'default',
      'badge': '1',
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'message_type': 'school_message',
      'class': _selectedClass ?? '',
      'section': _selectedSection ?? '',
      'recipient_type': _recipientType,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    try {
      // Send to multiple tokens (batch)
      for (int i = 0; i < tokens.length; i += 500) {
        List<String> batch = tokens.skip(i).take(500).toList();

        final Map<String, dynamic> message = {
          'notification': notification,
          'data': data,
          'registration_ids': batch,
          'priority': 'high',
          'content_available': true,
        };

        final response = await http.post(
          Uri.parse(fcmUrl),
          headers: {
            'Authorization': 'key=$_serverKey',
            'Content-Type': 'application/json',
          },
          body: json.encode(message),
        );

        if (response.statusCode == 200) {
          print(
              'FCM notification sent successfully to batch ${(i ~/ 500) + 1}');
        } else {
          print('Failed to send FCM notification: ${response.body}');
        }
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
      throw e;
    }
  }

  List<String> _availableStudents = [];
  bool _isLoadingStudents = false;

  // Updated function to load students using AssessmentService
  Future<void> _loadStudents() async {
    if (_selectedClass != null && _selectedSection != null) {
      setState(() {
        _isLoadingStudents = true;
        _availableStudents.clear();
        _selectedStudents.clear();
      });

      try {
        final assessmentService = AssessmentService();
        final students = await assessmentService.getStudentsByClassAndSection(
          _selectedClass!,
          _selectedSection!,
        );

        List<String> studentIdentifiers = students.map((student) {
          // Use roll number if available, otherwise use name
          return student['rollNo']?.toString().isNotEmpty == true
              ? student['rollNo'].toString()
              : student['name'].toString();
        }).toList();

        setState(() {
          _availableStudents = studentIdentifiers;
          _isLoadingStudents = false;
        });

        print(
            'Loaded ${studentIdentifiers.length} students for $_selectedClass - $_selectedSection');
      } catch (e) {
        print('Error loading students: $e');
        setState(() {
          _isLoadingStudents = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading students: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _availableStudents.clear();
        _selectedStudents.clear();
      });
    }
  }

  // Function to send topic-based notification (alternative approach)
  Future<void> _sendTopicNotification(String title, String body) async {
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    // Create topic based on class, section, and recipient type
    String topic = '${_selectedClass}${_selectedSection}$_recipientType'
        .replaceAll(' ', '_')
        .toLowerCase();

    final Map<String, dynamic> message = {
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
      },
      'data': {
        'message_type': 'school_message',
        'class': _selectedClass ?? '',
        'section': _selectedSection ?? '',
        'recipient_type': _recipientType,
      },
      'to': '/topics/$topic',
      'priority': 'high',
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Authorization': 'key=$_serverKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('Topic notification sent successfully to: $topic');
      } else {
        print('Failed to send topic notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending topic notification: $e');
      throw e;
    }
  }

  void _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStudents.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one student'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Sending message...'),
            ],
          ),
        ),
      );

      try {
        // Store message in Firestore
        DocumentReference messageRef =
            await FirebaseFirestore.instance.collection('messages').add({
          'title': _titleController.text.trim(),
          'body': _messageController.text.trim(),
          'class': _selectedClass,
          'section': _selectedSection,
          'students': _selectedStudents,
          'recipientType': _recipientType,
          'timestamp': Timestamp.fromDate(DateTime.now()),
          'status': 'sent',
          'notificationSent': false,
          'recipientCount': 0,
        });

        // Get recipient tokens
        List<String> recipientTokens = await _getRecipientTokens();

        // Send FCM notifications
        if (recipientTokens.isNotEmpty) {
          await _sendFCMNotification(
            recipientTokens,
            _titleController.text.trim(),
            _messageController.text.trim(),
          );
        }

        // Update message status
        await messageRef.update({
          'notificationSent': true,
          'recipientCount': recipientTokens.length,
        });

        // Hide loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Message sent to $_recipientType successfully! (${recipientTokens.length} recipients)'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        // Hide loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool allSelected = _availableStudents.isNotEmpty &&
        _selectedStudents.length == _availableStudents.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Dropdown
              const Text(
                'Class',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedClass,
                items: _classes.map((cls) {
                  return DropdownMenuItem(value: cls, child: Text(cls));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                    _selectedSection = null; // Reset section when class changes
                    _selectedStudents.clear(); // Clear selected students
                    _availableStudents.clear(); // Clear available students
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) =>
                    value == null ? 'Please select a class' : null,
              ),
              const SizedBox(height: 16),

              // Section Dropdown
              const Text(
                'Section',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSection,
                items: _sections.map((sec) {
                  return DropdownMenuItem(value: sec, child: Text(sec));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value;
                    _selectedStudents.clear(); // Clear selected students
                  });
                  _loadStudents(); // Load students for new section
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) =>
                    value == null ? 'Please select a section' : null,
              ),
              const SizedBox(height: 16),

              // Student Multi-select section
              const Text(
                'Select Students',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Show loading indicator while loading students
              if (_isLoadingStudents)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Loading students...'),
                      ],
                    ),
                  ),
                )
              else if (_availableStudents.isEmpty &&
                  _selectedClass != null &&
                  _selectedSection != null)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No students found for the selected class and section.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else if (_availableStudents.isNotEmpty) ...[
                // Select All checkbox
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: allSelected,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedStudents = List.from(_availableStudents);
                            } else {
                              _selectedStudents.clear();
                            }
                          });
                        },
                      ),
                      const Text(
                        'Select All',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Students list with checkboxes
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _availableStudents.map((student) {
                        return CheckboxListTile(
                          title: Text(student),
                          value: _selectedStudents.contains(student),
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                _selectedStudents.add(student);
                              } else {
                                _selectedStudents.remove(student);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Show selected count
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected: ${_selectedStudents.length} of ${_availableStudents.length} students',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Please select class and section to load students.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Recipient type: Radio buttons
              const Text(
                'Send To',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: ['Only Students', 'Only Parents', 'Both'].map((type) {
                  return RadioListTile(
                    title: Text(type),
                    value: type,
                    groupValue: _recipientType,
                    onChanged: (value) {
                      setState(() => _recipientType = value!);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Message Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Message Title',
                  border: OutlineInputBorder(),
                  hintText: 'E.g., Exam Reminder',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter title'
                    : null,
              ),
              const SizedBox(height: 16),

              // Message Body
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Type your message here...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter message'
                    : null,
              ),
              const SizedBox(height: 24),

              // Send Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedStudents.isNotEmpty ? _sendMessage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedStudents.isNotEmpty
                        ? Colors.green
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _selectedStudents.isEmpty
                        ? 'Select students to send message'
                        : 'Send Message & Notify (${_selectedStudents.length} students)',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:achiver_app/services/gemini_service.dart';
import 'package:achiver_app/services/doubt_service.dart';

class DoubtsPage extends StatefulWidget {
  const DoubtsPage({super.key});

  @override
  State<DoubtsPage> createState() => _DoubtsPageState();
}

class _DoubtsPageState extends State<DoubtsPage> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _messages =
      []; // Changed to non-final to allow reassignment
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();
  late final DoubtService _doubtService;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId; // Will store the student's roll number
  String? _selectedSubject;
  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Social Studies',
    'Computer Science',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _doubtService = DoubtService();
    // Get the current user's ID (roll number)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId =
            user.uid; // Or use a field from user data that contains roll number
      });
    }
    _loadPreviousDoubts();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadPreviousDoubts() async {
    if (_currentUserId == null) return;

    try {
      /* Backend TODO: Fetch previous doubts from backend (API call, database read) */
      final snapshot =
          await _doubtService.getStudentDoubts(_currentUserId!).first;
      if (snapshot.docs.isNotEmpty) {
        // Convert Firestore docs to message format
        final loadedMessages = <Map<String, dynamic>>[];

        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final message = {
            'id': doc.id,
            'type': data['imageUrl'] != null ? 'image' : 'text',
            'content': data['message'],
            'response': data['response'],
            'isUser': true,
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
          };
          loadedMessages.add(message);
        }

        if (mounted) {
          setState(() {
            _messages = loadedMessages;
          });
        }
      }
    } catch (e) {
      /* Backend TODO: Handle error fetching doubts from backend */
      if (kDebugMode) {
        print('Error loading previous doubts: $e');
      }
    }
  }

  Future<void> _saveDoubtToDatabase(String message, String response,
      {String? imageUrl, String? subject}) async {
    if (_currentUserId == null) return;

    try {
      /* Backend TODO: Save doubt to backend (API call, database write, file upload if image) */
      await _doubtService.saveDoubt(
        studentRollNumber: _currentUserId!,
        message: message,
        subject: subject,
        imageUrl: imageUrl,
        response: response,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      /* Backend TODO: Handle error saving doubt to backend */
      if (kDebugMode) {
        print('Error saving doubt: $e');
      }
      // Optionally show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save your doubt. Please try again.')),
        );
      }
    }
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;

    // Include subject in the prompt if selected
    final String prompt = _selectedSubject != null 
        ? '[$_selectedSubject] $text'
        : text;

    setState(() {
      _messages.insert(0, {
        "type": "text", 
        "content": _selectedSubject != null 
            ? '($_selectedSubject) $text' 
            : text, 
        "isUser": true
      });
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      /* Backend TODO: Integrate with external AI service for response generation */
      final response = await _geminiService.generateResponse(prompt);
      setState(() {
        _messages
            .insert(0, {"type": "text", "content": response, "isUser": false});
      });
      _scrollToBottom();

      // Save the doubt and response to Firestore with subject
      await _saveDoubtToDatabase(
        _selectedSubject != null ? '[$_selectedSubject] $text' : text, 
        response,
        subject: _selectedSubject,
      );
    } catch (e) {
      /* Backend TODO: Handle error from external AI service */
      if (kDebugMode) {
        print('Error sending text: $e');
      }
      setState(() {
        _messages.insert(0, {
          "type": "text",
          "content":
              "I apologize, but I couldn't process your request. Please try again.",
          "isUser": false
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _messages.insert(
            0, {"type": "image", "content": image.path, "isUser": true});
      });
      _scrollToBottom();

      try {
        /* Backend TODO: Integrate with external AI image analysis service */
        final response = await _geminiService.analyzeImage(image.path, '');
        setState(() {
          _messages.insert(
              0, {"type": "text", "content": response, "isUser": false});
        });
        _scrollToBottom();

        // Save the image doubt and response to Firestore
        // Note: In a real app, you'd want to upload the image to Firebase Storage
        // and save the download URL instead of the local path
        await _saveDoubtToDatabase(
          'Image question',
          response,
          imageUrl: image.path,
        );
      } catch (e) {
        /* Backend TODO: Handle error from external AI image analysis service */
        if (kDebugMode) {
          print('Error analyzing image: $e');
        }
        setState(() {
          _messages.insert(0, {
            "type": "text",
            "content":
                "I apologize, but I couldn't analyze the image. Please try uploading it again.",
            "isUser": false
          });
        });
      }
    } catch (e) {
      /* Backend TODO: Handle error picking image */
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] == true;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: Radius.circular(isUser ? 5 : 20),
            bottomLeft: Radius.circular(isUser ? 20 : 5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isUser ? Colors.blue.shade100 : Colors.purple.shade100,
                  radius: 16,
                  child: Icon(
                    isUser ? Icons.person : Icons.school,
                    color:
                        isUser ? Colors.blue.shade700 : Colors.purple.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isUser ? 'You' : 'Study Buddy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isUser ? Colors.blue.shade700 : Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            message['type'] == 'text'
                ? SelectableText(
                    message['content'],
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(message['content']),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Study Buddy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.school, color: Colors.purple.shade400),
                      const SizedBox(width: 8),
                      const Text('Welcome to Study Buddy!'),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I\'m your personal AI study assistant! Here\'s how I can help:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text('• Ask any academic questions'),
                      Text('• Upload images of problems or notes'),
                      Text('• Get step-by-step explanations'),
                      Text('• Practice with sample questions'),
                      Text('• Understand complex concepts'),
                      SizedBox(height: 12),
                      Text(
                        'Just type your question or upload an image to get started!',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Got it!'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subject selection dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Select Subject (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No specific subject'),
                  ),
                  ..._subjects.map((subject) => DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.purple.shade700),
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 72,
                            color: Colors.purple.shade200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hello! I\'m your Study Buddy!',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask me anything about your studies',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.shade100
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildSuggestion(
                                  'How do I solve quadratic equations?',
                                  Icons.functions,
                                ),
                                const Divider(),
                                _buildSuggestion(
                                  'Explain photosynthesis process',
                                  Icons.nature,
                                ),
                                const Divider(),
                                _buildSuggestion(
                                  'What are Newton\'s laws of motion?',
                                  Icons.speed,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: _messages.length,
                      itemBuilder: (_, index) =>
                          _buildMessage(_messages[index]),
                    ),
            ),
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Thinking...',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.image_outlined),
                      color: Colors.purple.shade700,
                      onPressed: _isLoading ? null : _pickImage,
                      tooltip: 'Upload an image',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              enabled: !_isLoading,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: _isLoading
                                    ? "Please wait..."
                                    : "Ask your question here...",
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color: Colors.purple.shade700,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_textController.text
                                          .trim()
                                          .isNotEmpty) {
                                        _sendText(_textController.text);
                                        _textController.clear();
                                      }
                                    },
                              tooltip: 'Send message',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(String text, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _textController.text = text;
          _sendText(text);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.purple.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
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

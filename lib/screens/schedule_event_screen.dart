import 'package:flutter/material.dart';

void main() {
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

  final List<String> _classes = ['Class 1', 'Class 2', 'Class 3'];
  final List<String> _sections = ['A', 'B', 'C'];
  final List<String> _allStudents = [
    'John Doe',
    'Jane Smith',
    'Alice Johnson',
    'Bob Brown',
  ];

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent to $_recipientType successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
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
    bool allSelected = _selectedStudents.length == _allStudents.length;

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
                  setState(() => _selectedClass = value);
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
                  setState(() => _selectedSection = value);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) =>
                    value == null ? 'Please select a section' : null,
              ),
              const SizedBox(height: 16),

              // Student Multi-select (basic version using checkboxes)
              const Text(
                'Select Students',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
                            _selectedStudents = List.from(_allStudents);
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
              ..._allStudents.map((student) {
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
              }),
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
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Send Message',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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

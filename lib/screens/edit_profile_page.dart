import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Static data matching ProfilePage
    final TextEditingController rollNoController =
        TextEditingController(text: '22CS123');
    final TextEditingController fullNameController =
        TextEditingController(text: 'Eswar Kumar');
    final TextEditingController classController =
        TextEditingController(text: '10th');
    final TextEditingController sectionController =
        TextEditingController(text: 'A');
    final TextEditingController parentEmailController =
        TextEditingController(text: 'parent@example.com');
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated (static, not saved)'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Roll Number (non-editable)
              TextFormField(
                controller: rollNoController,
                decoration: InputDecoration(
                  labelText: 'Roll Number',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                readOnly: true,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Class
              TextFormField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your class';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Section
              TextFormField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your section';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Parent Email
              TextFormField(
                controller: parentEmailController,
                decoration: const InputDecoration(
                  labelText: 'Parent Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter parent email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

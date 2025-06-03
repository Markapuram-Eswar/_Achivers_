import 'package:flutter/material.dart';
import '../services/ProfileService.dart'; // Import the service
import '../services/auth_service.dart'; // For fetching roll number or ID

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
<<<<<<< HEAD
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final EditProfileService _editProfileService = EditProfileService();

  // Controllers
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isSaving = false;
  String? _rollNumber;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _rollNoController.dispose();
    _fullNameController.dispose();
    _classController.dispose();
    _sectionController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      // Get roll number from AuthService
      _rollNumber = await AuthService.getUserId();

      // Get profile data
      final profile = await _editProfileService.getStudentProfile();

      setState(() {
        _rollNoController.text = _rollNumber ?? '';
        _fullNameController.text = profile['fullName']?.toString() ?? '';
        _classController.text = profile['class']?.toString() ?? '';
        _sectionController.text = profile['section']?.toString() ?? '';
        _parentEmailController.text = profile['parentEmail']?.toString() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _editProfileService.updateStudentProfile(
        fullName: _fullNameController.text,
        studentClass: _classController.text,
        section: _sectionController.text,
        parentEmail: _parentEmailController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
=======
>>>>>>> d02b87fe6d1aa927508a32534ea81c579578c01e
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
<<<<<<< HEAD
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
=======
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated (static, not saved)'),
                    backgroundColor: Colors.green,
>>>>>>> d02b87fe6d1aa927508a32534ea81c579578c01e
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
<<<<<<< HEAD
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Roll Number (read-only)
                    TextFormField(
                      controller: _rollNoController,
                      decoration: InputDecoration(
                        labelText: 'Roll Number',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      readOnly: true,
                      enabled: false,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter your full name'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Class
                    TextFormField(
                      controller: _classController,
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter your class'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Section
                    TextFormField(
                      controller: _sectionController,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.assignment_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter your section'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Parent Email
                    TextFormField(
                      controller: _parentEmailController,
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
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
=======
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
>>>>>>> d02b87fe6d1aa927508a32534ea81c579578c01e
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

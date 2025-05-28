import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/registration_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _selectedRole = 0; // 0: Student, 1: Teacher, 2: Parent
  bool _isLoading = false;

  // Form controllers - common fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Student specific
  final _rollNumberController = TextEditingController();
  final _classController = TextEditingController();
  final _sectionController = TextEditingController();

  // Teacher specific
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();

  // Parent specific
  final _childRollNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollNumberController.dispose();
    _classController.dispose();
    _sectionController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _childRollNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final registrationService = RegistrationService();

      switch (_selectedRole) {
        case 0: // Student
          /* Backend TODO: Register student (API call, database write) */
          await registrationService.registerStudent(
            rollNumber: _rollNumberController.text.trim(),
            name: _nameController.text.trim(),
            className: _classController.text.trim(),
            section: _sectionController.text.trim(),
            parentEmail: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
          );
          break;

        case 1: // Teacher
          /* Backend TODO: Register teacher (API call, database write) */
          await registrationService.registerTeacher(
            employeeId: _employeeIdController.text.trim(),
            name: _nameController.text.trim(),
            department: _departmentController.text.trim(),
          );
          break;

        case 2: // Parent
          /* Backend TODO: Register parent (API call, database write) */
          await registrationService.registerParent(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            childRollNumber: _childRollNumberController.text.trim(),
          );
          break;
      }

      Fluttertoast.showToast(msg: 'Registration successful!');

      // Navigate back to login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      /* Backend TODO: Handle registration error responses from backend */
      Fluttertoast.showToast(
        msg: 'Registration failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRoleName() {
    switch (_selectedRole) {
      case 0:
        return 'Student';
      case 1:
        return 'Teacher';
      case 2:
        return 'Parent';
      default:
        return '';
    }
  }

  Widget _buildStudentForm() {
    return Column(
      children: [
        _buildTextField('Roll Number',
            controller: _rollNumberController, isRequired: true),
        _buildTextField('Full Name',
            controller: _nameController, isRequired: true),
        _buildTextField('Class',
            controller: _classController, isRequired: true),
        _buildTextField('Section',
            controller: _sectionController, isRequired: true),
        _buildTextField('Parent Email (optional)',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildTeacherForm() {
    return Column(
      children: [
        _buildTextField('Employee ID',
            controller: _employeeIdController, isRequired: true),
        _buildTextField('Full Name',
            controller: _nameController, isRequired: true),
        _buildTextField('Department',
            controller: _departmentController, isRequired: true),
        _buildTextField('Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            isRequired: true),
      ],
    );
  }

  Widget _buildParentForm() {
    return Column(
      children: [
        _buildTextField("Child's Roll Number",
            controller: _childRollNumberController, isRequired: true),
        _buildTextField('Your Full Name',
            controller: _nameController, isRequired: true),
        _buildTextField('Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            isRequired: true),
        _buildTextField('Email (optional)',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildForm() {
    switch (_selectedRole) {
      case 0:
        return _buildStudentForm();
      case 1:
        return _buildTeacherForm();
      case 2:
        return _buildParentForm();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Let's Get Started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Register As
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Register As',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildRoleRadio(0, 'Student'),
                            const SizedBox(width: 8),
                            _buildRoleRadio(1, 'Teacher'),
                            const SizedBox(width: 8),
                            _buildRoleRadio(2, 'Parent'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dynamic form based on role
                  _buildForm(),

                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB547),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Register as ${_getRoleName()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFFB547),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildRoleRadio(int value, String label) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedRole,
          activeColor: const Color(0xFFFFB547),
          onChanged: _isLoading
              ? null
              : (val) {
                  setState(() {
                    _selectedRole = val!;
                  });
                },
        ),
        Text(label, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (keyboardType == TextInputType.emailAddress &&
              value != null &&
              value.isNotEmpty &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          if (keyboardType == TextInputType.phone &&
              value != null &&
              value.isNotEmpty &&
              !RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }
}

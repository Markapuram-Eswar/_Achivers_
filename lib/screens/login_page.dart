import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  bool _isLoading = false;
  int _selectedRole = 0; // 0: Student, 1: Teacher, 2: Parent

  @override
  void initState() {
    super.initState();
    // Set the orientation to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> saveFcmTokenToFirestore(
      String uid, String name, String? rollNumber) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();

      if (token != null && uid.isNotEmpty) {
        Map<String, dynamic> userData = {
          'name': name,
          'fcmToken': token,
          'lastLogin': FieldValue.serverTimestamp(),
        };

        // Add role-specific data
        switch (_selectedRole) {
          case 0: // Student
            userData.addAll({
              'role': 'student',
              'rollNumber': rollNumber ?? _idController.text.trim(),
              'class': 'Class 1', // Update as needed
              'section': 'A',
            });
            break;
          case 1: // Teacher
            userData.addAll({
              'role': 'teacher',
              'employeeId': _idController.text.trim(),
            });
            break;
          case 2: // Parent
            userData.addAll({
              'role': 'parent',
              'childRollNumber': _idController.text.trim(),
            });
            break;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(userData, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      // Don't throw error here as login should still succeed
    }
  }

  Widget _buildRoleRadio(int index, String title) {
    return ChoiceChip(
      label: Text(
        title,
        style: TextStyle(
          color: _selectedRole == index ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: _selectedRole == index,
      selectedColor: const Color(0xFFFFB547),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedRole = index;
        });
      },
    );
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
        return 'User';
    }
  }

  String _getIdFieldLabel() {
    switch (_selectedRole) {
      case 0:
        return 'Roll Number';
      case 1:
        return 'Employee ID';
      case 2:
        return "Child's Roll Number";
      default:
        return 'ID';
    }
  }

  String? _validateId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter ${_getIdFieldLabel().toLowerCase()}';
    }

    // Add specific validation based on role
    switch (_selectedRole) {
      case 0: // Student roll number validation
        if (value.length < 2) {
          return 'Roll number must be at least 2 characters';
        }
        break;
      case 1: // Teacher employee ID validation
        if (value.length < 3) {
          return 'Employee ID must be at least 3 characters';
        }
        break;
      case 2: // Parent child roll number validation
        if (value.length < 2) {
          return 'Child roll number must be at least 2 characters';
        }
        break;
    }

    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final inputId = _idController.text.trim();

      Map<String, dynamic>? userData;
      String uid = '';
      String name = '';
      String? rollNumber;

      switch (_selectedRole) {
        case 0: // Student
          userData = await authService.loginStudent(inputId);
          break;
        case 1: // Teacher
          userData = await authService.loginTeacher(inputId);
          break;
        case 2: // Parent
          userData = await authService.loginParent(inputId);
          break;
      }

      if (userData != null) {
        uid = userData['uid']?.toString() ?? '';
        name = userData['name']?.toString() ?? _getRoleName();
        rollNumber = userData['rollNumber']?.toString();

        if (uid.isEmpty) {
          throw Exception('Invalid user credentials');
        }

        // Save FCM token to Firestore
        await saveFcmTokenToFirestore(uid, name, rollNumber);

        // Show success message
        Fluttertoast.showToast(
          msg: 'Logged in successfully as $name',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate to appropriate dashboard
        if (mounted) {
          switch (_selectedRole) {
            case 0: // Student
              Navigator.pushReplacementNamed(context, '/welcome_page');
              break;
            case 1: // Teacher
              Navigator.pushReplacementNamed(context, '/teacher-dashboard');
              break;
            case 2: // Parent
              Navigator.pushReplacementNamed(context, '/parent-dashboard');
              break;
          }
        }
      } else {
        throw Exception('Login failed: Invalid credentials');
      }
    } catch (e) {
      String errorMessage = 'Login failed';

      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('not found')) {
        errorMessage =
            'User not found. Please check your ${_getIdFieldLabel().toLowerCase()}.';
      } else if (e.toString().contains('Invalid')) {
        errorMessage = 'Invalid credentials. Please try again.';
      } else {
        errorMessage =
            'Login failed: ${e.toString().replaceAll('Exception: ', '')}';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.4,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                // Login As
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login As',
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
                const SizedBox(height: 18),
                // Card-like login form
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // ID Field
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _idController,
                                decoration: InputDecoration(
                                  hintText: 'Enter ${_getIdFieldLabel()}',
                                  border: const UnderlineInputBorder(),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: _validateId,
                                enabled: !_isLoading,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB547),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
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
                                    'Login as ${_getRoleName()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFB547),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

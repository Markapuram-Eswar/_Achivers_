import 'package:flutter/material.dart';
import 'take_attendance_screen.dart';
import 'grade_assignments_screen.dart';
import 'schedule_event_screen.dart';
import 'create_test_screen.dart';
import 'teacher_profile_page.dart';
import 'student_details_screen.dart';
import '../services/auth_service.dart';
import '../services/teacher_profile_service.dart';

void main() {
  runApp(const MaterialApp(
    home: TeacherDashboardScreen(),
  ));
}

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Map<String, dynamic>? teacherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeacherProfile();
  }

  Future<void> fetchTeacherProfile() async {
    final String? teacherId = await AuthService.getUserId();
    if (teacherId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final profile = await ProfileService().getTeacherProfile(teacherId);
    setState(() {
      teacherData = profile;
      isLoading = false;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue[900],
          title: const Text(
            'Teacher Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherProfilePage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildLeaveAppointments(context), // Add this new section
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final String teacherName = teacherData?['name'] ?? 'Teacher';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $teacherName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have 3 classes scheduled for today',
            style: TextStyle(
              color: Colors.blue[50],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.1, // Slightly taller tiles to accommodate the text
      children: [
        // First Row
        _buildActionCard(
          'Take Attendance',
          Icons.how_to_reg,
          Colors.green[400]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TakeAttendanceScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          'Grade Assignments',
          Icons.assignment_turned_in,
          Colors.orange[400]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EnterMarksScreen(),
              ),
            );
          },
        ),

        // Second Row
        _buildActionCard(
          'Schedule Event',
          Icons.event_available,
          Colors.purple[400]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendMessageScreen(),
              ),
            );
          },
        ),

        // Third Row
        _buildActionCard(
          'Create Test',
          Icons.quiz,
          Colors.red[400]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateTestScreen(),
              ),
            );
          },
        ),

        // Fourth Row - Student Details
        _buildActionCard(
          'Student Details',
          Icons.people,
          Colors.teal[400]!,
          onTap: () {
            // Student data is now handled within StudentDetailsScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentDetailsScreen(),
              ),
            );
            // Note: The StudentDetailsScreen now handles student data internally
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this new method to build the leave appointments section
  Widget _buildLeaveAppointments(BuildContext context) {
    // Sample leave appointment data - in a real app, this would come from a database
    final List<Map<String, dynamic>> leaveAppointments = [
      {
        'studentName': 'Rahul Kumar',
        'class': '8-A',
        'startDate': '15/05/2023',
        'endDate': '18/05/2023',
        'reason': 'Family function',
        'status': 'Pending'
      },
      {
        'studentName': 'Priya Sharma',
        'class': '10-A',
        'startDate': '20/05/2023',
        'endDate': '22/05/2023',
        'reason': 'Medical appointment',
        'status': 'Pending'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Leave Appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all leave appointments
              },
              child: Text(
                'View All',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (leaveAppointments.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No pending leave appointments',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaveAppointments.length > 2
                ? 2
                : leaveAppointments.length, // Show only 2 items in dashboard
            itemBuilder: (context, index) {
              final appointment = leaveAppointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      appointment['studentName'][0],
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    appointment['studentName'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Class ${appointment['class']} • ${appointment['startDate']} to ${appointment['endDate']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment['status'],
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Reason: ${appointment['reason']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  // Handle rejection logic
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle approval logic
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

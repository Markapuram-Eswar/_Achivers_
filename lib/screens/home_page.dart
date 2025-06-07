import 'package:achiver_app/screens/contact_teacher_screen.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'tasks_screen.dart';
import 'doubts_page.dart';
import 'reports_zone_page.dart';
import 'timetable_page.dart';
import 'welcome_page.dart';
import 'progress_page.dart';
import 'practice_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyHomePage(
    selectedTheme: 'Game Display',
    documentId: 'Profile', // Make sure this document exists in Firestore
  ));
}

class MyHomePage extends StatefulWidget {
  final String documentId; // e.g., 'achievers_profile'

  final VoidCallback? onThemeToggle;
  final String selectedTheme;

  const MyHomePage({
    super.key,
    this.onThemeToggle,
    required this.selectedTheme,
    this.documentId = 'Profile', // Default document ID
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<String> _labels = ['Home', 'Classes', 'Contacts', 'Profile'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    /* Backend TODO: Fetch home page data from backend (API call, database read) */
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    print('Navigating to index: $index'); // Debug print
    if (_pageController.hasClients) {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = _selectedIndex == index;
    final List<String> iconUrls = [
      'https://img.icons8.com/arcade/64/country-house.png',
      'https://img.icons8.com/arcade/64/15.png',
      'https://img.icons8.com/arcade/64/new-post--v2.png',
      'https://img.icons8.com/arcade/64/gender-neutral-user--v2.png',
    ];
    final iconUrl = iconUrls[index];

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 36,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(iconUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              if (isSelected)
                Text(
                  _labels[index],
                  style: TextStyle(
                    fontSize: 11,
                    color: _getThemeColor(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('schoolprofile')
          .doc(widget.documentId)
          .snapshots(),
      builder: (context, snapshot) {
        // Enhanced error handling
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading school profile...'),
                ],
              ),
            ),
          );
        }

        // Check if document exists
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 50),
                  const SizedBox(height: 16),
                  Text(
                      'Document "${widget.documentId}" not found in "schoolprofile" collection'),
                  const SizedBox(height: 8),
                  const Text('Please check your Firestore setup'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        // Check if data exists
        if (data == null || data.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.data_object, color: Colors.blue, size: 50),
                  const SizedBox(height: 16),
                  const Text('No data found in document'),
                  const SizedBox(height: 8),
                  Text('Document ID: ${widget.documentId}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Extract data with fallbacks
        final logoUrl = data['appLogo']?.toString() ?? '';
        final appName = data['appName']?.toString() ?? 'School App';

        // Debug print (remove in production)
        print('Firebase data loaded: appName=$appName, logoUrl=$logoUrl');

        return Container(
          decoration: _getThemeDecoration(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: _getThemeColor(),
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: logoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              logoUrl,
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator(
                                    strokeWidth: 2);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Logo loading error: $error');
                                return const Icon(Icons.school,
                                    color: Colors.black);
                              },
                            ),
                          )
                        : const Icon(Icons.school, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appName,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://img.icons8.com/isometric/50/appointment-reminders.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/welcome');
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://img.icons8.com/isometric/50/video-card.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              children: [
                _buildHomePage(context),
              ],
            ),
            bottomNavigationBar: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(
                    _labels.length, (index) => _buildNavItem(index)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(_getLogoAsset(), height: 150),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 16,
              children: [
                _buildFeatureCard(
                    'Practice Zone',
                    Colors.orange,
                    () => const PracticePage(),
                    'https://img.icons8.com/isometric/50/minecraft-logo.png'),
                _buildFeatureCard(
                    'Test Zone',
                    Colors.pinkAccent,
                    () => const TasksScreen(),
                    'https://img.icons8.com/isometric/50/test-tube.png'),
                _buildFeatureCard(
                    'Reports',
                    Colors.blue,
                    () => ReportsZonePage(),
                    'https://img.icons8.com/isometric/50/report-card.png'),
                _buildFeatureCard(
                    'Classtable',
                    Colors.purple,
                    () => const AttendanceCalendarPage(),
                    'https://img.icons8.com/isometric/50/stopwatch.png'),
                _buildFeatureCard(
                    'Progress',
                    Colors.yellow[700]!,
                    () => const ProgressPage(),
                    'https://img.icons8.com/isometric/50/positive-dynamic.png'),
                _buildFeatureCard(
                    'Doubts',
                    Colors.redAccent,
                    () => const DoubtsPage(),
                    'https://img.icons8.com/isometric/50/ask-question.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, Color color,
      Widget Function() pageBuilder, String iconUrl) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 120,
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => pageBuilder())),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(iconUrl),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getThemeColor() {
    switch (widget.selectedTheme) {
      case 'STUDENT DISPLAY':
        return Colors.blue;
      case 'Park Display':
        return Colors.green;
      case 'Game Display':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }

  BoxDecoration _getThemeDecoration() {
    switch (widget.selectedTheme) {
      case 'STUDENT DISPLAY':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Colors.white],
          ),
        );
      case 'Park Display':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF81C784), Color(0xFFA5D6A7)],
          ),
        );
      case 'Game Display':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF8A65), Color(0xFFFFAB91)],
          ),
        );
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Colors.white],
          ),
        );
    }
  }

  String _getLogoAsset() {
    switch (widget.selectedTheme) {
      case 'STUDENT DISPLAY':
        return 'assets/logo/logo_student.png';
      case 'Park Display':
        return 'assets/logo/logo_park.png';
      case 'Game Display':
        return 'assets/logo/logo_game.png';
      default:
        return 'assets/images/logo.png';
    }
  }
}

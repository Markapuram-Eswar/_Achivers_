import 'package:achiver_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/welcome_page.dart';
import 'screens/payment_screen.dart';
import 'screens/notification_page.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/parent_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Logging the error but continuing app execution as Firebase is not critical
    debugPrint('Firebase initialization error: $e');
  }

  // Add error boundary
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Achiever App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/payment': (context) => const PaymentScreen(),
        '/welcome_page': (context) => const WelcomePage(),
        '/notifications': (context) => const NotificationPage(),
        '/teacher-dashboard': (context) => const TeacherDashboardScreen(),
        '/parent-dashboard': (context) => const ParentDashboardScreen(),
      },
    );
  }
}

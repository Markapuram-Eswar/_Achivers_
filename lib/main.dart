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
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔹 Ask for notification permissions
    NotificationSettings settings = await messaging.requestPermission();

    // 🔹 Use `settings` to respond or log permission result
    debugPrint('🔔 FCM Permission Status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission.');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('❌ User denied notification permission.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      debugPrint('❓ Notification permission not determined.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️ Provisional permission granted (iOS only).');
    }

    // 🔹 (Optional) Handle foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        debugPrint(
            '📨 Foreground notification: ${message.notification!.title}');
      }
    });
  } catch (e) {
    debugPrint('🔥 Firebase initialization error: $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
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

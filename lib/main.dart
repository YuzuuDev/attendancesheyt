import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'supabase_client.dart';
import 'app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 1. FIREBASE MUST COME FIRST
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔴 2. REQUEST NOTIFICATION PERMISSION
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 🔴 3. INIT SUPABASE AFTER FIREBASE
  await SupabaseClientInstance.init();

  final isLoggedIn =
      SupabaseClientInstance.supabase.auth.currentUser != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Attendance',
      theme: AppTheme.theme,
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'supabase_client.dart';
import 'app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/push_notification_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientInstance.init();

  final isLoggedIn =
      SupabaseClientInstance.supabase.auth.currentUser != null;
  
  await Firebase.initializeApp();

    // 🔴 REQUIRED FOR ANDROID 13+ AND IOS
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Attendance',
      theme: AppTheme.theme,
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}
*/

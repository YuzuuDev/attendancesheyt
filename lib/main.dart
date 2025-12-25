import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'supabase_client.dart';
import 'app_theme.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientInstance.init();
  //initizalize OneSignal / pushing notifications
  await initOneSignal();

  final isLoggedIn =
      SupabaseClientInstance.supabase.auth.currentUser != null;

  runApp(
    MyApp(
      isLoggedIn: isLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    required this.isLoggedIn,
    super.key,
  });
  
  Future<void> initOneSignal() async {
    OneSignal.initialize('ONESIGNAL_APP_ID');
    OneSignal.Notifications.requestPermission(true);
  }
  
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

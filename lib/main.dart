import 'package:flutter/material.dart';                // For Flutter widgets
import 'supabase_client.dart';                        // Your Supabase init
import 'screens/login_screen.dart';                           // Login page
import 'screens/home_screen.dart';   

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientInstance.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return MaterialApp(
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}

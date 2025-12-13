import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://cvgrnnobgegbuioetkud.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2Z3Jubm9iZ2VnYnVpb2V0a3VkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1MjA0MDIsImV4cCI6MjA4MTA5NjQwMn0.jeznMcCyf1unOYrKpm8ayf4jwVb_kGoWFDGRZT_QJqw',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

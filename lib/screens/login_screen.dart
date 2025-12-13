import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response.user != null) {
      final userId = response.user!.id;
      final res = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .single()
          .execute();

      if (res.error == null) {
        if (res.data['role'] == 'teacher') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => TeacherDashboard()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => StudentDashboard()));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.error?.message}')));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: loading ? CircularProgressIndicator() : Text('Login'))
          ],
        ),
      ),
    );
  }
}

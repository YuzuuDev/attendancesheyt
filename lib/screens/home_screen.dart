import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../supabase_client.dart';
import 'teachers/create_class_screen.dart';
import 'students/join_class_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  String role = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _loadUserRole() async {
    final userId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final response = await SupabaseClientInstance.supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    setState(() {
      role = response?['role'] ?? 'student';
      isLoading = false;
    });
  }

  void _logout() async {
    await authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: role == 'teacher'
            ? Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) => CreateClassScreen()));
                      },
                      child: Text("Create Class")),
                  SizedBox(height: 10),
                  // You can later add "View My Classes" button here
                  Text("You are logged in as Teacher"),
                ],
              )
            : Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) => JoinClassScreen()));
                      },
                      child: Text("Join Class")),
                  SizedBox(height: 10),
                  Text("You are logged in as Student"),
                ],
              ),
      ),
    );
  }
}

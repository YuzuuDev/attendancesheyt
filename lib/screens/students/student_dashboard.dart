import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../services/auth_service.dart';
import '../../supabase_client.dart';
import 'join_class_screen.dart';

class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ClassService classService = ClassService();
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() async {
    final studentId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final result = await classService.getStudentClasses(studentId);
    setState(() {
      classes = result;
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("Student Dashboard"),
        backgroundColor: Colors.green[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                elevation: 5,
              ),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Join Class", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JoinClassScreen()),
                ).then((_) => _loadClasses());
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: classes.isEmpty
                  ? Center(child: Text("No classes joined yet", style: TextStyle(color: Colors.green[900])))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, index) {
                        final cls = classes[index]['classes'];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.green[100],
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(cls['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Code: ${cls['code']}"),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../services/auth_service.dart';
import '../../supabase_client.dart';
import 'create_class_screen.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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
    final teacherId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final result = await classService.getTeacherClasses(teacherId);
    setState(() {
      classes = result;
      isLoading = false;
    });
  }

  void _logout() async {
    await authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showStudents(String classId, String className) async {
    final students = await classService.getStudents(classId);

    // Fix: Supabase returns List<Map<String, dynamic>> where profile data is under 'profiles'
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text("Students in $className", style: TextStyle(color: Colors.green[800])),
        content: SizedBox(
          width: double.maxFinite,
          child: students.isEmpty
              ? Center(child: Text("No students enrolled"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (_, index) {
                    final profile = students[index]['profiles'] ?? {};
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.green[100],
                      child: ListTile(
                        title: Text(profile['full_name'] ?? "Unknown"),
                        subtitle: Text(profile['role'] ?? ""),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("Teacher Dashboard"),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateClassScreen()),
                ).then((_) => _loadClasses());
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Create New Class", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: classes.isEmpty
                  ? Center(child: Text("No classes created yet", style: TextStyle(color: Colors.green[900])))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, index) {
                        final cls = classes[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.green[100],
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(cls['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Code: ${cls['code']}"),
                            trailing: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[300],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              icon: Icon(Icons.group, color: Colors.white),
                              label: Text("Students", style: TextStyle(color: Colors.white)),
                              onPressed: () => _showStudents(cls['id'], cls['name']),
                            ),
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

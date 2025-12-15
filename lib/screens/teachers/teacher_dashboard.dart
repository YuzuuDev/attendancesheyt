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
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Do you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  
    if (shouldLogout == true) {
      await authService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }


  void _showStudents(String classId, String className) async {
    // ✅ Show a loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    // Fetch students
    final students = await classService.getStudents(classId);

    // Close loading
    Navigator.pop(context);

    // Show actual students
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Students in $className"),
        content: SizedBox(
          width: double.maxFinite,
          child: students.isEmpty
              ? const Text("No students enrolled")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (_, index) {
                    final profile = students[index]['profiles'];
                    return ListTile(
                      title: Text(profile?['full_name'] ?? 'Unknown'),
                      subtitle: Text(profile?['role'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateClassScreen()),
                ).then((_) => _loadClasses());
              },
              child: const Text("Create Class"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: classes.isEmpty
                  ? const Center(child: Text("No classes"))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, index) {
                        final cls = classes[index];
                        return Card(
                          child: ListTile(
                            title: Text(cls['name']),
                            subtitle: Text("Code: ${cls['code']}"),
                            trailing: ElevatedButton(
                              onPressed: () =>
                                  _showStudents(cls['id'], cls['name']),
                              child: const Text("Students"),
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

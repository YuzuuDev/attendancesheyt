import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../supabase_client.dart';
import 'create_class_screen.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final ClassService classService = ClassService();
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

  void _showStudents(String classId, String className) async {
    final students = await classService.getStudents(classId);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Students in $className"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: students.length,
            itemBuilder: (_, index) {
              final student = students[index]['profiles'];
              return ListTile(
                title: Text(student['full_name'] ?? "Unknown"),
                subtitle: Text(student['role'] ?? ""),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text("Teacher Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateClassScreen()))
                    .then((_) => _loadClasses());
              },
              child: Text("Create New Class"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (_, index) {
                  final cls = classes[index];
                  return Card(
                    child: ListTile(
                      title: Text(cls['name']),
                      subtitle: Text("Code: ${cls['code']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.group),
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

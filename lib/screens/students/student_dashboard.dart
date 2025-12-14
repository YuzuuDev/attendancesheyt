import 'package:flutter/material.dart';
import '../services/class_service.dart';
import '../supabase_client.dart';
import 'join_class_screen.dart';

class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ClassService classService = ClassService();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text("Student Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => JoinClassScreen()))
                    .then((_) => _loadClasses());
              },
              child: Text("Join Class"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (_, index) {
                  final cls = classes[index]['classes'];
                  return Card(
                    child: ListTile(
                      title: Text(cls['name']),
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

import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import '../../supabase_client.dart';
import 'create_assignment_screen.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  final String classId;
  final String className;

  const TeacherAssignmentsScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> {
  final AssignmentService assignmentService = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final res = await assignmentService.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assignments - ${widget.className}"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAssignmentScreen(classId: widget.classId),
            ),
          ).then((_) => _loadAssignments());
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text("No assignments yet"))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (_, i) {
                    final a = assignments[i];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(a['title']),
                        subtitle: Text(a['description'] ?? ''),
                        trailing: Text(
                          a['due_date'] != null
                              ? DateTime.parse(a['due_date'])
                                  .toLocal()
                                  .toString()
                                  .substring(0, 16)
                              : 'No due date',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

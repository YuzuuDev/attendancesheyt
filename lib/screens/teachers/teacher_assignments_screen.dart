import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'create_assignment_screen.dart';
import 'assignment_submissions_screen.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  final String classId;

  const TeacherAssignmentsScreen({
    required this.classId,
    super.key,
  });

  @override
  State<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState
    extends State<TeacherAssignmentsScreen> {
  final AssignmentService assignmentService = AssignmentService();
  List<Map<String, dynamic>> assignments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res =
        await assignmentService.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await assignmentService.deleteAssignment(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateAssignmentScreen(classId: widget.classId),
            ),
          );
          _load();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (_, i) {
                final a = assignments[i];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(a['title']),
                    subtitle:
                        Text(a['description'] ?? ''),
                    onTap: () async {
                      // EDIT assignment
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreateAssignmentScreen(
                            classId: widget.classId,
                            assignment: a,
                          ),
                        ),
                      );
                      _load();
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.folder),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AssignmentSubmissionsScreen(
                                  assignmentId: a['id'],
                                  title: a['title'],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _delete(a['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

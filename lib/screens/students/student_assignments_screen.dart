import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentAssignmentsScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  final AssignmentService assignmentService = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await assignmentService.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),
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
                    subtitle: Text(a['description'] ?? ''),
                    trailing: ElevatedButton(
                            child: const Text("Submit / View"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubmitAssignmentScreen(
                                    assignmentId: a['id'],
                                    title: a['title'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

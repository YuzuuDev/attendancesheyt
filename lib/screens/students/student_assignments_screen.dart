import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String classId;

  const StudentAssignmentsScreen({
    required this.classId,
    super.key,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen> {
  final AssignmentService service = AssignmentService();
  List<Map<String, dynamic>> assignments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await service.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignments")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text("No assignments"))
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
                        trailing: ElevatedButton(
                          child: const Text("Submit"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SubmitAssignmentScreen(
                                  assignmentId: a['id'],
                                  title: a['title'],
                                ),
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

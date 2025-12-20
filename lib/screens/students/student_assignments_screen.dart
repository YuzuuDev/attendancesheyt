import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String classId;

  const StudentAssignmentsScreen({
    super.key,
    required this.classId,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen> {
  final AssignmentService _service = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final res = await _service.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text('No assignments yet'))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final a = assignments[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(a['title']),
                        subtitle: Text(a['description'] ?? ''),
                        trailing: ElevatedButton(
                          child: const Text('Submit'),
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
                      ),
                    );
                  },
                ),
    );
  }
}

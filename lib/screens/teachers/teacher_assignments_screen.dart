import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'create_assignment_screen.dart';
import 'assignment_submissions_screen.dart';
import 'create_recitation_question_screen.dart'; // ✅ ADD THIS

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
  final AssignmentService service = AssignmentService();
  List<Map<String, dynamic>> assignments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    assignments = await service.getAssignments(widget.classId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignments")),
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
                final type = a['assignment_type']; // ✅ READ TYPE

                return ListTile(
                  title: Text(a['title']),
                  subtitle: Text(
                    "${a['description'] ?? ''} • ${type.toUpperCase()}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.folder),
                    onPressed: () {
                      // 🔥 THIS IS WHERE IT GOES — EXACTLY HERE
                      if (type == 'recitation') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateRecitationQuestionScreen(
                              assignmentId: a['id'],
                            ),
                          ),
                        );
                        return;
                      }

                      // ✅ DEFAULT: ACTIVITY / FILE SUBMISSIONS
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
                );
              },
            ),
    );
  }
}

/*import 'package:flutter/material.dart';
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
  final AssignmentService service = AssignmentService();
  List<Map<String, dynamic>> assignments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    assignments = await service.getAssignments(widget.classId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignments")),
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

                return ListTile(
                  title: Text(a['title']),
                  subtitle: Text(a['description'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.folder),
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
                );
              },
            ),
    );
  }
}*/

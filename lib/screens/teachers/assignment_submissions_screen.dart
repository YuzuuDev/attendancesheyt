import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class AssignmentSubmissionsScreen extends StatefulWidget {
  final String assignmentId;
  final String title;

  const AssignmentSubmissionsScreen({
    required this.assignmentId,
    required this.title,
    super.key,
  });

  @override
  State<AssignmentSubmissionsScreen> createState() =>
      _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState
    extends State<AssignmentSubmissionsScreen> {
  final AssignmentService service = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await service.getSubmissions(widget.assignmentId);
    setState(() {
      submissions = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions yet"))
              : ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (_, i) {
                    final s = submissions[i];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(s['student_id']),
                        subtitle: Text(s['submitted_at'] ?? ''),
                        trailing: const Icon(Icons.insert_drive_file),
                      ),
                    );
                  },
                ),
    );
  }
}

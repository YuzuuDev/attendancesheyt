import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class AssignmentSubmissionsScreen extends StatelessWidget {
  final String assignmentId;
  final String title;

  const AssignmentSubmissionsScreen({
    required this.assignmentId,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final service = AssignmentService();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getSubmissions(assignmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final submissions = snapshot.data ?? [];

          if (submissions.isEmpty) {
            return const Center(child: Text("No submissions yet"));
          }

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (_, i) {
              final s = submissions[i];
              final profile = s['profiles'];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                      profile?['full_name'] ?? s['student_id']),
                  subtitle: Text(
                    s['submitted_at'] != null
                        ? DateTime.parse(s['submitted_at'])
                            .toLocal()
                            .toString()
                        : '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      // open s['file_url']
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
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
}*/

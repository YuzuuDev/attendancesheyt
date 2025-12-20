import 'package:flutter/material.dart';
import '../../supabase_client.dart';

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
  bool loading = true;
  List<Map<String, dynamic>> submissions = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      final data = await SupabaseClientInstance.supabase
          .from('assignment_submissions')
          .select('''
            id,
            file_url,
            submitted_at,
            profiles (
              full_name
            )
          ''')
          .eq('assignment_id', widget.assignmentId)
          .order('submitted_at', ascending: false);

      setState(() {
        submissions = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint('LOAD ERROR: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions yet"))
              : ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (_, index) {
                    final s = submissions[index];
                    final profile = s['profiles'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title:
                            Text(profile?['full_name'] ?? 'Unknown Student'),
                        subtitle: Text(
                          s['submitted_at'] != null
                              ? DateTime.parse(s['submitted_at'])
                                  .toLocal()
                                  .toString()
                              : '',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            // open file_url in browser or viewer
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/*import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import '../../services/participation_service.dart';

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
  final AssignmentService assignmentService = AssignmentService();
  final ParticipationService participationService =
      ParticipationService();

  List<Map<String, dynamic>> submissions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res =
        await assignmentService.getSubmissions(widget.assignmentId);
    setState(() {
      submissions = res;
      loading = false;
    });
  }

  Future<void> _grade(
    String submissionId,
    String studentId,
    int points,
    String feedback,
  ) async {
    await assignmentService.gradeSubmission(
      submissionId: submissionId,
      grade: points,
      feedback: feedback,
    );

    await participationService.addPoints(
      studentId: studentId,
      points: points,
    );

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: submissions.length,
              itemBuilder: (_, i) {
                final s = submissions[i];
                final profile = s['profiles'];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title:
                        Text(profile?['full_name'] ?? 'Unknown'),
                    subtitle: Text(
                      s['grade'] != null
                          ? "Grade: ${s['grade']}"
                          : "Not graded",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final pointsCtrl =
                            TextEditingController();
                        final feedbackCtrl =
                            TextEditingController();

                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Grade"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: pointsCtrl,
                                  keyboardType:
                                      TextInputType.number,
                                  decoration:
                                      const InputDecoration(
                                          labelText: "Points"),
                                ),
                                TextField(
                                  controller: feedbackCtrl,
                                  decoration:
                                      const InputDecoration(
                                          labelText: "Feedback"),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _grade(
                                    s['id'],
                                    s['student_id'],
                                    int.parse(
                                        pointsCtrl.text),
                                    feedbackCtrl.text,
                                  );
                                  Navigator.pop(context);
                                },
                                child:
                                    const Text("Save"),
                              ),
                            ],
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
}*/

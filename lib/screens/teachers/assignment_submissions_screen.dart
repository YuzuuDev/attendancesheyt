import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/assignment_service.dart';

class AssignmentSubmissionsScreen extends StatelessWidget {
  final String assignmentId;
  final String title;

  const AssignmentSubmissionsScreen({
    required this.assignmentId,
    required this.title,
    super.key,
  });

  bool _isImage(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.gif') ||
        u.endsWith('.webp');
  }

  Future<void> _downloadAndOpen(
    BuildContext context,
    String signedUrl,
  ) async {
    final uri = Uri.parse(signedUrl);

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open file')),
      );
    }
  }

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
            return Center(child: Text(snapshot.error.toString()));
          }

          final submissions = snapshot.data ?? [];
          if (submissions.isEmpty) {
            return const Center(child: Text('No submissions yet'));
          }

          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (_, i) {
              final s = submissions[i];
              final profile = s['profile'];
              final signedUrl = s['signed_url'];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // STUDENT NAME
                      Text(
                        profile?['full_name'] ?? s['student_id'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // DATE
                      if (s['submitted_at'] != null)
                        Text(
                          DateTime.parse(s['submitted_at'])
                              .toLocal()
                              .toString(),
                          style: const TextStyle(fontSize: 12),
                        ),

                      const SizedBox(height: 12),

                      // IMAGE PREVIEW (ONLY IMAGES)
                      if (_isImage(signedUrl))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            signedUrl,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Text('Failed to load image'),
                          ),
                        ),

                      // DOWNLOAD BUTTON (NON-IMAGES)
                      if (!_isImage(signedUrl))
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download & Open'),
                          onPressed: () =>
                              _downloadAndOpen(context, signedUrl),
                        ),
                    ],
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
import 'package:url_launcher/url_launcher.dart';
import 'submission_preview_screen.dart';



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
              final profile = s['profile'];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    profile?['full_name'] ?? s['student_id'],
                  ),
                  subtitle: Text(
                    s['submitted_at'] != null
                        ? DateTime.parse(s['submitted_at'])
                            .toLocal()
                            .toString()
                        : '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      final url = s['file_url'];
                      if (url == null) return;
                  
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmissionPreviewScreen(
                            fileUrl: url,
                          ),
                        ),
                      );
                    },
                  ),

                  // 👇 THIS IS THE FUCKING PART YOU ASKED FOR
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        final gradeCtrl = TextEditingController();
                        final feedbackCtrl = TextEditingController();
              
                        return AlertDialog(
                          title: const Text("Grade Submission"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: gradeCtrl,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(labelText: "Grade"),
                              ),
                              TextField(
                                controller: feedbackCtrl,
                                decoration:
                                    const InputDecoration(labelText: "Feedback"),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                await service.gradeSubmission(
                                  submissionId: s['id'],
                                  grade: int.parse(gradeCtrl.text),
                                  feedback: feedbackCtrl.text,
                                );
                                Navigator.pop(context);
                              },
                              child: const Text("Save"),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}*/

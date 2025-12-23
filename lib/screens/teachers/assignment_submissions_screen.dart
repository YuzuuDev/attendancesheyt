import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/assignment_service.dart';

class AssignmentSubmissionsScreen extends StatelessWidget {
  final String assignmentId;
  final String title;

  const AssignmentSubmissionsScreen({
    required this.assignmentId,
    required this.title,
    super.key,
  });

  bool _isImage(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.gif') ||
        p.endsWith('.webp');
  }

  Future<File> _download(String signedUrl) async {
    final uri = Uri.parse(signedUrl);
    final client = HttpClient();
    final req = await client.getUrl(uri);
    final res = await req.close();

    final bytes =
        await consolidateHttpClientResponseBytes(res);

    final dir = await getApplicationDocumentsDirectory();
    final name = uri.pathSegments.last.split('?').first;
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void _gradeDialog(
    BuildContext context,
    AssignmentService service,
    Map<String, dynamic> s,
  ) {
    final gradeCtrl =
        TextEditingController(text: s['grade']?.toString());
    final feedbackCtrl =
        TextEditingController(text: s['feedback']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Grade (${s['grade'] ?? '-'} / ${s['max_points']})"),
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
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final grade = int.parse(gradeCtrl.text);
              if (grade < 0 || grade > s['max_points']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Grade must be between 0 and ${s['max_points']}")),
                );
                return;
              }
              
              await service.gradeSubmission(
                submissionId: s['id'],
                grade: grade,
                feedback: feedbackCtrl.text.isEmpty ? null : feedbackCtrl.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = AssignmentService();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getSubmissions(assignmentId),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data = snap.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final s = data[i];
              final path = s['file_url'];
              final signed = s['signed_url'];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['student_id'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      if (s['grade'] != null)
                        Text("Grade: ${s['grade']}"),
                      const SizedBox(height: 8),
                      if (path != null &&
                          signed != null &&
                          _isImage(path))
                        Image.network(
                          signed,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open File"),
                        onPressed: () async {
                          final f = await _download(signed);
                          await OpenFilex.open(f.path);
                        },
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _gradeDialog(context, service, s),
                        child: const Text("Grade"),
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

/*import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/assignment_service.dart';

class AssignmentSubmissionsScreen extends StatelessWidget {
  final String assignmentId;
  final String title;

  const AssignmentSubmissionsScreen({
    required this.assignmentId,
    required this.title,
    super.key,
  });

  bool _isImage(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.gif') ||
        p.endsWith('.webp');
  }

  bool _isVideo(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.mp4') ||
        p.endsWith('.mov') ||
        p.endsWith('.webm') ||
        p.endsWith('.avi');
  }

  Future<File> _download(String signedUrl) async {
    final uri = Uri.parse(signedUrl);
    final client = HttpClient();
    final req = await client.getUrl(uri);
    final res = await req.close();

    final bytes =
        await consolidateHttpClientResponseBytes(res);

    final dir = await getApplicationDocumentsDirectory();
    final name = uri.pathSegments.last.split('?').first;
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final service = AssignmentService();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getSubmissions(assignmentId),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final data = snap.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final s = data[i];
              final path = s['file_url'];
              final signed = s['signed_url'];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['student_id'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      /// 🖼️ IMAGE PREVIEW
                      if (path != null &&
                          signed != null &&
                          _isImage(path))
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(8),
                          child: Image.network(
                            signed,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),

                      /// 🎞️ VIDEO PREVIEW
                      if (path != null &&
                          signed != null &&
                          _isVideo(path))
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label:
                            const Text('Download & Open'),
                        onPressed: () async {
                          final f = await _download(signed);
                          await OpenFilex.open(f.path);
                        },
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
}*/

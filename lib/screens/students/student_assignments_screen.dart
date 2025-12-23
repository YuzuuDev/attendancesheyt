import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  bool _isPastDue(String? due) {
    if (due == null) return false;
    return DateTime.parse(due).isBefore(DateTime.now());
  }

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

  Future<void> _downloadAndOpen(
    BuildContext context,
    String signedUrl,
  ) async {
    try {
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
      await OpenFilex.open(file.path);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (_, i) {
                final a = assignments[i];
                final locked =
                    a['is_locked'] == true || _isPastDue(a['due_date']);
                final filePath = a['instruction_file_url'];
                final signed = a['instruction_signed_url'];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (a['description'] != null &&
                            a['description'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(a['description']),
                          ),

                        const SizedBox(height: 10),

                        if (filePath != null &&
                            signed != null &&
                            _isImage(filePath))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              signed,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),

                        if (filePath != null &&
                            signed != null &&
                            _isVideo(filePath))
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 64,
                                color: Colors.black54,
                              ),
                            ),
                          ),

                        if (signed != null)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label:
                                const Text("Download Instructions"),
                            onPressed: () =>
                                _downloadAndOpen(context, signed),
                          ),

                        const Divider(),

                        /// 🔽 SUBMISSION STATE
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _service.getMySubmission(a['id']),
                          builder: (_, snap) {
                            /// ❌ NOT SUBMITTED
                            if (!snap.hasData ||
                                snap.data == null) {
                              return ElevatedButton(
                                onPressed: locked
                                    ? null
                                    : () async {
                                        final res =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SubmitAssignmentScreen(
                                              assignmentId: a['id'],
                                              title: a['title'],
                                            ),
                                          ),
                                        );
                                        if (res == true) {
                                          setState(() {});
                                        }
                                      },
                                child: Text(
                                    locked ? "Locked" : "Submit"),
                              );
                            }

                            /// ✅ SUBMITTED — REPLACE + UNSUBMIT
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "✅ Submitted",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// 🔁 REPLACE FILE
                                ElevatedButton.icon(
                                  icon:
                                      const Icon(Icons.swap_horiz),
                                  label:
                                      const Text("Replace File"),
                                  onPressed: locked
                                      ? null
                                      : () async {
                                          final res =
                                              await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  SubmitAssignmentScreen(
                                                assignmentId:
                                                    a['id'],
                                                title: a['title'],
                                              ),
                                            ),
                                          );
                                          if (res == true) {
                                            setState(() {});
                                          }
                                        },
                                ),

                                const SizedBox(height: 6),

                                /// 🗑 UNSUBMIT
                                ElevatedButton.icon(
                                  icon:
                                      const Icon(Icons.delete),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.orange,
                                  ),
                                  label:
                                      const Text("Unsubmit"),
                                  onPressed: locked
                                      ? null
                                      : () async {
                                          await _service.unsubmit(
                                            a['id'],
                                            Supabase.instance
                                                .client
                                                .auth
                                                .currentUser!
                                                .id,
                                          );
                                          setState(() {});
                                        },
                                ),
                              ],
                            );
                          },
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


/*import 'package:flutter/material.dart';
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6, 
                      child: ListTile(
                        title: Text(
                          a['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// 🔽 THIS IS WHERE YOUR FUTUREBUILDER GOES
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a['description'] != null &&
                                a['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(a['description']),
                              ),

                            const SizedBox(height: 6),

                            /// ✅ ADDED — submission status
                            FutureBuilder<Map<String, dynamic>?>(
                              future: _service.getMySubmission(a['id']),
                              builder: (_, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Checking submission...",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }

                                if (!snap.hasData || snap.data == null) {
                                  return const Text(
                                    "❌ Not submitted",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                final sub = snap.data!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "✅ Submitted",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (sub['grade'] != null)
                                      Text(
                                        "Grade: ${sub['grade']}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (sub['feedback'] != null &&
                                        sub['feedback']
                                            .toString()
                                            .isNotEmpty)
                                      Text(
                                        "Feedback: ${sub['feedback']}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),

                        /// ✅ SUBMIT BUTTON — UNTOUCHED
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
}*/

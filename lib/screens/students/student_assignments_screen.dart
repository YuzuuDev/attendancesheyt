import 'dart:io';
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
  Map<String, Map<String, dynamic>> mySubmissions = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);

    assignments = await _service.getAssignments(widget.classId);

    mySubmissions.clear();
    for (final a in assignments) {
      final sub = await _service.getMySubmission(a['id']);
      if (sub != null) {
        mySubmissions[a['id']] = sub;
      }
    }

    setState(() => loading = false);
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

                final instructionPath =
                    a['instruction_file_url'];
                final instructionSigned =
                    a['instruction_signed_url'];

                final submission = mySubmissions[a['id']];
                final isSubmitted = submission != null;

                final submissionPath = submission?['file_url'];
                final submissionSigned = submission?['signed_url'];

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

                        /// ---------- INSTRUCTIONS ----------
                        if (instructionPath != null &&
                            instructionSigned != null &&
                            _isImage(instructionPath))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              instructionSigned,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),

                        if (instructionSigned != null)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label:
                                const Text("Download Instructions"),
                            onPressed: () => _downloadAndOpen(
                                context, instructionSigned),
                          ),

                        const Divider(),

                        /// ---------- SUBMISSION PREVIEW ----------
                        if (isSubmitted &&
                            submissionPath != null &&
                            submissionSigned != null &&
                            _isImage(submissionPath))
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Submission:",
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: Image.network(
                                  submissionSigned,
                                  key: ValueKey(submissionSigned),
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),

                        if (isSubmitted &&
                            submissionSigned != null &&
                            !_isImage(submissionPath ?? ''))
                          ElevatedButton.icon(
                            icon:
                                const Icon(Icons.open_in_new),
                            label:
                                const Text("Open Submission"),
                            onPressed: () =>
                                _downloadAndOpen(
                                    context, submissionSigned),
                          ),

                        /// ========== ✅ GRADING DISPLAY (HERE) ==========
                        if (isSubmitted &&
                            submission != null &&
                            submission['grade'] != null)
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const Text(
                                "Status: Graded",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                "Grade: ${submission['grade']} / ${a['max_points']}",
                                style:
                                    const TextStyle(fontSize: 16),
                              ),
                              if (submission['feedback'] != null &&
                                  submission['feedback']
                                      .toString()
                                      .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6),
                                  child: Text(
                                    "Feedback: ${submission['feedback']}",
                                    style: const TextStyle(
                                        fontStyle:
                                            FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        /// =============================================

                        const Divider(),

                        /// ---------- FLOW ----------
                        if (!isSubmitted)
                          ElevatedButton(
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
                                      await _loadAll();
                                    }
                                  },
                            child:
                                Text(locked ? "Locked" : "Submit"),
                          ),

                        if (isSubmitted)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.orange,
                            ),
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

                                    mySubmissions
                                        .remove(a['id']);
                                    setState(() {});
                                  },
                            child: const Text("Unsubmit"),
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

/*import 'dart:io';
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
  Map<String, Map<String, dynamic>> mySubmissions = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);

    assignments = await _service.getAssignments(widget.classId);

    mySubmissions.clear();
    for (final a in assignments) {
      final sub = await _service.getMySubmission(a['id']);
      if (sub != null) {
        mySubmissions[a['id']] = sub;
      }
    }

    setState(() => loading = false);
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

                final instructionPath =
                    a['instruction_file_url'];
                final instructionSigned =
                    a['instruction_signed_url'];

                final submission = mySubmissions[a['id']];
                final isSubmitted = submission != null;

                final submissionPath = submission?['file_url'];
                final submissionSigned = submission?['signed_url'];

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

                        /// ---------- INSTRUCTIONS ----------
                        if (instructionPath != null &&
                            instructionSigned != null &&
                            _isImage(instructionPath))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              instructionSigned,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),

                        if (instructionSigned != null)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label:
                                const Text("Download Instructions"),
                            onPressed: () => _downloadAndOpen(
                                context, instructionSigned),
                          ),

                        const Divider(),

                        /// ---------- SUBMISSION PREVIEW (FIXED) ----------
                        if (isSubmitted &&
                            submissionPath != null &&
                            submissionSigned != null &&
                            _isImage(submissionPath))
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Submission:",
                                style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(10),
                                child: Image.network(
                                  submissionSigned,
                                  key: ValueKey(
                                      submissionSigned), // 🔥 FIX
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),

                        if (isSubmitted &&
                            submissionSigned != null &&
                            !_isImage(submissionPath ?? ''))
                          ElevatedButton.icon(
                            icon:
                                const Icon(Icons.open_in_new),
                            label:
                                const Text("Open Submission"),
                            onPressed: () =>
                                _downloadAndOpen(
                                    context, submissionSigned),
                          ),

                        const Divider(),

                        /// ---------- FLOW ----------
                        if (!isSubmitted)
                          ElevatedButton(
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
                                      await _loadAll();
                                    }
                                  },
                            child:
                                Text(locked ? "Locked" : "Submit"),
                          ),

                        if (isSubmitted)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.orange,
                            ),
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

                                    mySubmissions
                                        .remove(a['id']);
                                    setState(() {});
                                  },
                            child: const Text("Unsubmit"),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}*/

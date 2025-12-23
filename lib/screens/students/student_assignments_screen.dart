import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_player/video_player.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String classId;
  const StudentAssignmentsScreen({super.key, required this.classId});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  final AssignmentService _service = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    assignments = await _service.getAssignments(widget.classId);
    setState(() => loading = false);
  }

  bool _isPastDue(String? due) =>
      due != null && DateTime.parse(due).isBefore(DateTime.now());

  bool _isImage(String p) =>
      p.endsWith('.png') ||
      p.endsWith('.jpg') ||
      p.endsWith('.jpeg') ||
      p.endsWith('.gif') ||
      p.endsWith('.webp');

  bool _isVideo(String p) =>
      p.endsWith('.mp4') ||
      p.endsWith('.mov') ||
      p.endsWith('.webm') ||
      p.endsWith('.avi');

  Future<void> _downloadAndOpen(String signedUrl) async {
    final uri = Uri.parse(signedUrl);
    final req = await HttpClient().getUrl(uri);
    final res = await req.close();
    final bytes = await consolidateHttpClientResponseBytes(res);

    final dir = await getApplicationDocumentsDirectory();
    final name = uri.pathSegments.last.split('?').first;
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
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
                final url = a['instruction_signed_url'];
                final path = a['instruction_file_url'] ?? '';

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['title'],
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),

                        if (a['description'] != null)
                          Text(a['description']),

                        const SizedBox(height: 8),

                        /// 🖼️ IMAGE PREVIEW
                        if (url != null && _isImage(path))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url, height: 180),
                          ),

                        /// 🎥 VIDEO PREVIEW
                        if (url != null && _isVideo(path))
                          SizedBox(
                            height: 200,
                            child: VideoPlayerWidget(url),
                          ),

                        if (url != null)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text("Download Instructions"),
                            onPressed: () => _downloadAndOpen(url),
                          ),

                        const Divider(),

                        FutureBuilder<Map<String, dynamic>?>(
                          future: _service.getMySubmission(a['id']),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return ElevatedButton(
                                onPressed: locked
                                    ? null
                                    : () async {
                                        final r = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SubmitAssignmentScreen(
                                              assignmentId: a['id'],
                                              title: a['title'],
                                            ),
                                          ),
                                        );
                                        if (r == true) setState(() {});
                                      },
                                child: Text(locked ? 'Locked' : 'Submit'),
                              );
                            }

                            return ElevatedButton(
                              onPressed: locked
                                  ? null
                                  : () async {
                                      await _service.unsubmit(
                                        a['id'],
                                        Supabase.instance.client.auth
                                            .currentUser!.id,
                                      );
                                      setState(() {});
                                    },
                              child:
                                  Text(locked ? 'Locked' : 'Unsubmit'),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// 🎥 SIMPLE VIDEO PLAYER
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget(this.url, {super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _c;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (!_c.value.isInitialized) return const SizedBox();
    return GestureDetector(
      onTap: () => _c.value.isPlaying ? _c.pause() : _c.play(),
      child: AspectRatio(
        aspectRatio: _c.value.aspectRatio,
        child: VideoPlayer(_c),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
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

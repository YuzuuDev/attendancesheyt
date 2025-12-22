import 'package:flutter/material.dart';
import '../../services/participation_service.dart';
import '../../supabase_client.dart';

class ParticipationScreen extends StatefulWidget {
  final String? classId;
  final String? className;

  const ParticipationScreen({
    this.classId,
    this.className,
    super.key,
  });

  @override
  State<ParticipationScreen> createState() => _ParticipationScreenState();
}

class _ParticipationScreenState extends State<ParticipationScreen> {
  final ParticipationService service = ParticipationService();
  List<Map<String, dynamic>> students = [];
  String reason = 'recitation';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // GLOBAL MODE — no class selected yet
    if (widget.classId == null) {
      setState(() => loading = false);
      return;
    }

    students = await service.getClassStudents(widget.classId!);
    setState(() => loading = false);
  }

  Future<void> _apply(String studentId, int points) async {
    await service.addPoints(
      classId: widget.classId!,
      studentId: studentId,
      points: points,
      reason: reason,
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.className == null
              ? 'Participation'
              : 'Participation – ${widget.className}',
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : widget.classId == null
              ? const Center(
                  child: Text(
                    'Select a class to manage participation.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    DropdownButton<String>(
                      value: reason,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(
                            value: 'recitation', child: Text('Recitation')),
                        DropdownMenuItem(
                            value: 'activity', child: Text('Activity')),
                        DropdownMenuItem(
                            value: 'lesson', child: Text('Lesson')),
                        DropdownMenuItem(
                            value: 'forum', child: Text('Forum')),
                      ],
                      onChanged: (v) => setState(() => reason = v!),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (_, i) {
                          final s = students[i];
                          final profile = s['profiles'];

                          return ListTile(
                            title: Text(profile['full_name']),
                            subtitle: Text(
                              'Points: ${profile['participation_points']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      _apply(s['student_id'], -1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _apply(s['student_id'], 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.exposure_plus_2),
                                  onPressed: () =>
                                      _apply(s['student_id'], 2),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}


/*import 'package:flutter/material.dart';
import '../../services/participation_service.dart';

class ParticipationScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ParticipationScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<ParticipationScreen> createState() => _ParticipationScreenState();
}

class _ParticipationScreenState extends State<ParticipationScreen> {
  final ParticipationService service = ParticipationService();
  List<Map<String, dynamic>> students = [];
  String reason = 'recitation';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    students = await service.getClassStudents(widget.classId);
    setState(() {});
  }

  Future<void> _apply(String studentId, int points) async {
    await service.addPoints(
      classId: widget.classId,
      studentId: studentId,
      points: points,
      reason: reason,
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Participation - ${widget.className}")),
      body: Column(
        children: [
          DropdownButton<String>(
            value: reason,
            items: const [
              DropdownMenuItem(value: 'recitation', child: Text('Recitation')),
              DropdownMenuItem(value: 'activity', child: Text('Activity')),
              DropdownMenuItem(value: 'lesson', child: Text('Lesson')),
              DropdownMenuItem(value: 'forum', child: Text('Forum')),
            ],
            onChanged: (v) => setState(() => reason = v!),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (_, i) {
                final s = students[i];
                final profile = s['profiles'];
                return ListTile(
                  title: Text(profile['full_name']),
                  subtitle: Text(
                      "Points: ${profile['participation_points']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _apply(s['student_id'], -1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _apply(s['student_id'], 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.exposure_plus_2),
                        onPressed: () => _apply(s['student_id'], 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/

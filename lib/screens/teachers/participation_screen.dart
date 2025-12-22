import 'package:flutter/material.dart';
import '../../services/participation_service.dart';
import '../../services/class_service.dart';

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
  final ClassService classService = ClassService();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> students = [];

  String? selectedClassId;
  String reason = 'recitation';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    classes = await classService.getTeacherClasses(
      service.currentUserId,
    );
    selectedClassId = widget.classId ?? classes.first['id'];
    await _loadStudents();
  }

  Future<void> _loadStudents() async {
    students = await service.getClassStudents(selectedClassId!);
    setState(() {});
  }

  Future<void> _apply(String studentId, int points) async {
    await service.addPoints(
      classId: selectedClassId!,
      studentId: studentId,
      points: points,
      reason: reason,
    );
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Participation")),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedClassId,
            items: classes
                .map(
                  (c) => DropdownMenuItem(
                    value: c['id'],
                    child: Text(c['name']),
                  ),
                )
                .toList(),
            onChanged: (v) {
              selectedClassId = v;
              _loadStudents();
            },
          ),
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

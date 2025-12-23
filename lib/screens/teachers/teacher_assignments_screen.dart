import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'create_assignment_screen.dart';
import 'assignment_submissions_screen.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  final String classId;

  const TeacherAssignmentsScreen({
    required this.classId,
    super.key,
  });

  @override
  State<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState
    extends State<TeacherAssignmentsScreen> {
  final AssignmentService service = AssignmentService();
  List<Map<String, dynamic>> assignments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    assignments = await service.getAssignments(widget.classId);
    setState(() => loading = false);
  }

  void _editAssignment(Map<String, dynamic> a) {
    //new shit
    final maxPointsCtrl = TextEditingController(text: a['max_points'].toString());

    final titleCtrl = TextEditingController(text: a['title']);
    final descCtrl = TextEditingController(text: a['description']);
    DateTime? dueDate =
        a['due_date'] != null ? DateTime.parse(a['due_date']).toLocal() : null;

    Uint8List? newBytes;
    String? newName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Assignment"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descCtrl,
                decoration:
                    const InputDecoration(labelText: "Description"),
              ),
              //new shit
              TextField(
                controller: maxPointsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Max Points (e.g. 10, 20, 100)",
                ),
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (d == null) return;

                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t == null) return;

                  setState(() {
                    dueDate = DateTime(
                        d.year, d.month, d.day, t.hour, t.minute).toUtc();
                  });
                },
                child: Text(dueDate == null
                    ? "Pick Due Date & Time"
                    : dueDate.toString()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final res =
                      await FilePicker.platform.pickFiles(
                    withData: true,
                  );
                  if (res != null &&
                      res.files.single.bytes != null) {
                    newBytes = res.files.single.bytes;
                    newName = res.files.single.name;
                  }
                },
                child: const Text("Replace Instruction File"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.updateAssignment(
                assignmentId: a['id'],
                title: titleCtrl.text,
                description: descCtrl.text,
                dueDate: dueDate,
              );
              //new shit
              await service.updateAssignmentMaxPoints(
                assignmentId: a['id'],
                maxPoints: int.parse(maxPointsCtrl.text),
              );

              if (newBytes != null && newName != null) {
                await service.updateInstructionFile(
                  assignmentId: a['id'],
                  bytes: newBytes!,
                  fileName: newName!,
                );
              }

              Navigator.pop(context);
              _load();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ===================== ADDITIVE: DELETE CONFIRM =====================
  void _confirmDelete(String assignmentId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Assignment"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.deleteAssignment(assignmentId);
              Navigator.pop(context);
              _load();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignments")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateAssignmentScreen(classId: widget.classId),
            ),
          );
          _load();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (_, i) {
                final a = assignments[i];
                final bool locked = a['is_locked'] == true;

                return ListTile(
                  title: Text(a['title']),
                  subtitle: Text(a['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ================= ADDITIVE: LOCK TOGGLE =================
                      IconButton(
                        icon: Icon(
                          locked ? Icons.lock : Icons.lock_open,
                          color: locked ? Colors.red : Colors.green,
                        ),
                        onPressed: () async {
                          await service.setAssignmentLock(
                              a['id'], !locked);
                          _load();
                        },
                      ),
                      // =========================================================

                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editAssignment(a),
                      ),

                      // ================= ADDITIVE: DELETE =================
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(a['id']),
                      ),
                      // ==================================================

                      IconButton(
                        icon: const Icon(Icons.folder),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AssignmentSubmissionsScreen(
                                assignmentId: a['id'],
                                title: a['title'],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/*import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'create_assignment_screen.dart';
import 'assignment_submissions_screen.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  final String classId;

  const TeacherAssignmentsScreen({
    required this.classId,
    super.key,
  });

  @override
  State<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState
    extends State<TeacherAssignmentsScreen> {
  final AssignmentService service = AssignmentService();
  List<Map<String, dynamic>> assignments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    assignments = await service.getAssignments(widget.classId);
    setState(() => loading = false);
  }

  void _editAssignment(Map<String, dynamic> a) {
    final titleCtrl = TextEditingController(text: a['title']);
    final descCtrl = TextEditingController(text: a['description']);
    DateTime? dueDate =
        a['due_date'] != null ? DateTime.parse(a['due_date']) : null;

    Uint8List? newBytes;
    String? newName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Assignment"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descCtrl,
                decoration:
                    const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (d == null) return;

                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t == null) return;

                  setState(() {
                    dueDate = DateTime(
                        d.year, d.month, d.day, t.hour, t.minute);
                  });
                },
                child: Text(dueDate == null
                    ? "Pick Due Date & Time"
                    : dueDate.toString()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final res =
                      await FilePicker.platform.pickFiles(
                    withData: true,
                  );
                  if (res != null &&
                      res.files.single.bytes != null) {
                    newBytes = res.files.single.bytes;
                    newName = res.files.single.name;
                  }
                },
                child: const Text("Replace Instruction File"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.updateAssignment(
                assignmentId: a['id'],
                title: titleCtrl.text,
                description: descCtrl.text,
                dueDate: dueDate,
              );

              if (newBytes != null && newName != null) {
                await service.updateInstructionFile(
                  assignmentId: a['id'],
                  bytes: newBytes!,
                  fileName: newName!,
                );
              }

              Navigator.pop(context);
              _load();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assignments")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateAssignmentScreen(classId: widget.classId),
            ),
          );
          _load();
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (_, i) {
                final a = assignments[i];

                return ListTile(
                  title: Text(a['title']),
                  subtitle: Text(a['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editAssignment(a),
                      ),
                      IconButton(
                        icon: const Icon(Icons.folder),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AssignmentSubmissionsScreen(
                                assignmentId: a['id'],
                                title: a['title'],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}*/

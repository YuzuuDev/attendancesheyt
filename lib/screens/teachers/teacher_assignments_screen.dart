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

  Future<void> _editAssignmentDialog(Map<String, dynamic> a) async {
    final titleCtrl = TextEditingController(text: a['title']);
    final descCtrl =
        TextEditingController(text: a['description'] ?? '');

    DateTime? due =
        a['due_date'] != null ? DateTime.parse(a['due_date']) : null;

    Uint8List? newBytes;
    String? newName;

    await showDialog(
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
                child: Text(
                  due == null
                      ? "Pick Due Date & Time"
                      : "Due: ${due!.toLocal()}",
                ),
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
                    due = DateTime(
                        d.year, d.month, d.day, t.hour, t.minute);
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text("Replace Instruction File"),
                onPressed: () async {
                  final res =
                      await FilePicker.platform.pickFiles(withData: true);
                  if (res != null &&
                      res.files.single.bytes != null) {
                    newBytes = res.files.single.bytes;
                    newName = res.files.single.name;
                  }
                },
              ),
              if (newName != null) Text(newName!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              await service.updateAssignment(
                assignmentId: a['id'],
                title: titleCtrl.text,
                description: descCtrl.text,
                dueDateTime: due,
                newInstructionBytes: newBytes,
                newInstructionName: newName,
              );
              Navigator.pop(context);
              _load();
            },
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
                        onPressed: () => _editAssignmentDialog(a),
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
}

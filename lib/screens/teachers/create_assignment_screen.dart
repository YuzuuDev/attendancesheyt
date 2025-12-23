import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;
  const CreateAssignmentScreen({required this.classId, super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final service = AssignmentService();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  DateTime? dueDateTime;
  Uint8List? instructionBytes;
  String? instructionName;

  Future<void> _pickDueDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      dueDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Assignment")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: "Description"),
          ),

          const SizedBox(height: 12),

          ElevatedButton.icon(
            icon: const Icon(Icons.attach_file),
            label: const Text("Attach Instruction File"),
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(
                withData: true,
              );
              if (res != null && res.files.single.bytes != null) {
                setState(() {
                  instructionBytes = res.files.single.bytes;
                  instructionName = res.files.single.name;
                });
              }
            },
          ),

          if (instructionName != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(instructionName!),
            ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _pickDueDateTime,
            child: const Text("Pick Due Date & Time"),
          ),

          if (dueDateTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(dueDateTime!.toLocal().toString()),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              await service.createAssignment(
                classId: widget.classId,
                title: titleCtrl.text,
                description: descCtrl.text,
                dueDate: dueDateTime,
                assignmentType: 'activity',
                instructionBytes: instructionBytes,
                instructionName: instructionName,
              );
              Navigator.pop(context);
            },
            child: const Text("Create Assignment"),
          ),
        ],
      ),
    );
  }
}




/*import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;

  const CreateAssignmentScreen({required this.classId, super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final AssignmentService service = AssignmentService();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? dueDate;
  String type = 'activity';

  Future<void> _create() async {
    await service.createAssignment(
      classId: widget.classId,
      title: titleCtrl.text,
      description: descCtrl.text,
      dueDate: dueDate,
      assignmentType: type,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Assignment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
            DropdownButton<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'recitation', child: Text('Recitation')),
                DropdownMenuItem(value: 'activity', child: Text('Activity')),
                DropdownMenuItem(value: 'lesson', child: Text('Lesson')),
                DropdownMenuItem(value: 'forum', child: Text('Forum')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            ElevatedButton(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => dueDate = d);
              },
              child: const Text("Pick Due Date"),
            ),
            ElevatedButton(onPressed: _create, child: const Text("Create")),
          ],
        ),
      ),
    );
  }
}*/

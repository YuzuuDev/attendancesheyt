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
}

/*import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;

  const CreateAssignmentScreen({
    required this.classId,
    super.key,
  });

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final AssignmentService service = AssignmentService();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? dueDate;
  bool loading = false;

  Future<void> _create() async {
    setState(() => loading = true);

    await service.createAssignment(
      classId: widget.classId,
      title: titleCtrl.text,
      description: descCtrl.text,
      dueDate: dueDate,
    );

    setState(() => loading = false);
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
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _create,
                    child: const Text("Create"),
                  ),
          ],
        ),
      ),
    );
  }
}*/

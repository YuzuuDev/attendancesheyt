import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import '../../supabase_client.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;
  final Map<String, dynamic>? assignment;

  const CreateAssignmentScreen({required this.classId, this.assignment, super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final AssignmentService assignmentService = AssignmentService();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? dueDate;
  bool loading = false;

  void _create() async {
    setState(() => loading = true);
  
    final err = await assignmentService.createAssignment(
      classId: widget.classId,
      title: titleCtrl.text,
      description: descCtrl.text,
      dueDate: dueDate,
    );
  
    setState(() => loading = false);
  
    if (err == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
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
              child: const Text("Pick Due Date"),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => dueDate = d);
              },
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _create,
                    child: const Text("Create Assignment"),
                  ),
          ],
        ),
      ),
    );
  }
}

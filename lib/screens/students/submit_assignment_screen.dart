import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import '../../supabase_client.dart';

class SubmitAssignmentScreen extends StatefulWidget {
  final String assignmentId;
  final String title;

  const SubmitAssignmentScreen({
    required this.assignmentId,
    required this.title,
    super.key,
  });

  @override
  State<SubmitAssignmentScreen> createState() =>
      _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {
  final AssignmentService assignmentService = AssignmentService();
  File? file;
  bool loading = false;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles();
    if (res != null) {
      setState(() => file = File(res.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (file == null) return;

    setState(() => loading = true);

    final studentId =
        SupabaseClientInstance.supabase.auth.currentUser!.id;

    final err = await assignmentService.submitAssignment(
      assignmentId: widget.assignmentId,
      //studentId: studentId,
      file: file!,
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
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Pick File"),
            ),
            if (file != null) Text(file!.path.split('/').last),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Submit Assignment"),
                  ),
          ],
        ),
      ),
    );
  }
}

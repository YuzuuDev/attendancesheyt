import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

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

class _SubmitAssignmentScreenState
    extends State<SubmitAssignmentScreen> {
  final AssignmentService service = AssignmentService();

  Uint8List? bytes;
  String? fileName;
  bool loading = false;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      withData: true,
    );

    if (res != null && res.files.single.bytes != null) {
      setState(() {
        bytes = res.files.single.bytes;
        fileName = res.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (bytes == null || fileName == null) return;

    setState(() => loading = true);

    final err = await service.submitAssignment(
      assignmentId: widget.assignmentId,
      fileBytes: bytes!,
      fileName: fileName!,
    );

    setState(() => loading = false);

    if (err == null) {
      Navigator.pop(context, true);
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
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickFile,
              label: const Text("Pick File"),
            ),
            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(fileName!),
              ),
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


/*import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

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
  final AssignmentService service = AssignmentService();
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

    final err = await service.submitAssignment(
      assignmentId: widget.assignmentId,
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
            if (file != null)
              Text(file!.path.split('/').last),
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
}*/

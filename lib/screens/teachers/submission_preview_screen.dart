import 'package:flutter/material.dart';
import 'file_preview.dart';

class SubmissionPreviewScreen extends StatelessWidget {
  final String fileUrl;

  const SubmissionPreviewScreen({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submission Preview')),
      body: FilePreview(fileUrl: fileUrl),
    );
  }
}

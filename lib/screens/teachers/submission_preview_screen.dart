import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'file_preview.dart';

class SubmissionPreviewScreen extends StatelessWidget {
  final String fileUrl;

  const SubmissionPreviewScreen({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Preview'),
        actions: [
          /// ⬇️ DOWNLOAD BUTTON — RIGHT HERE
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final res = await http.get(Uri.parse(fileUrl));
              final dir = await getApplicationDocumentsDirectory();
              final ext = fileUrl.split('.').last.split('?').first;
              final file = File('${dir.path}/assignment.$ext');
              await file.writeAsBytes(res.bodyBytes);
              OpenFilex.open(file.path);
            },
          )
        ],
      ),

      /// 👇 PREVIEW CONTENT
      body: FilePreview(fileUrl: fileUrl),
    );
  }
}

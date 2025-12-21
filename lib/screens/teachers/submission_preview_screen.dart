import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;

class SubmissionPreviewScreen extends StatefulWidget {
  final String fileUrl;

  const SubmissionPreviewScreen({
    required this.fileUrl,
    super.key,
  });

  @override
  State<SubmissionPreviewScreen> createState() =>
      _SubmissionPreviewScreenState();
}

class _SubmissionPreviewScreenState extends State<SubmissionPreviewScreen> {
  bool loading = false;
  String? error;

  Future<File> _downloadFile() async {
    final uri = Uri.parse(widget.fileUrl);
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Download failed');
    }

    final dir = await getTemporaryDirectory();
    final fileName = uri.pathSegments.last;
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(res.bodyBytes);
    return file;
  }

  Future<void> _preview() async {
    setState(() => loading = true);
    try {
      final file = await _downloadFile();
      await OpenFilex.open(file.path);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _downloadOnly() async {
    setState(() => loading = true);
    try {
      await _downloadFile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded')),
      );
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
              onPressed: loading ? null : _preview,
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              onPressed: loading ? null : _downloadOnly,
            ),

            const Spacer(),

            if (loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionPreviewScreen extends StatelessWidget {
  final String fileUrl;

  const SubmissionPreviewScreen({
    required this.fileUrl,
    super.key,
  });

  bool _isImage(String url) {
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp');
  }

  bool _isPdf(String url) {
    return url.endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    if (_isImage(fileUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fileUrl,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Text("Image preview failed"),
        ),
      );
    }

    if (_isPdf(fileUrl)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PDF file"),
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Open PDF"),
            onPressed: () async {
              final uri = Uri.parse(fileUrl);
              await launchUrl(uri,
                  mode: LaunchMode.externalApplication);
            },
          ),
        ],
      );
    }

    /// EVERYTHING ELSE (DOCX, ZIP, ETC.)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("File"),
        TextButton.icon(
          icon: const Icon(Icons.download),
          label: const Text("Open / Download"),
          onPressed: () async {
            final uri = Uri.parse(fileUrl);
            await launchUrl(uri,
                mode: LaunchMode.externalApplication);
          },
        ),
      ],
    );
  }
}*/

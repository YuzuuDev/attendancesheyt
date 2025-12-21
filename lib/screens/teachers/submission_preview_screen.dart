import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionPreviewScreen extends StatelessWidget {
  final String fileUrl;

  const SubmissionPreviewScreen({
    super.key,
    required this.fileUrl,
  });

  bool _isImage(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.gif') ||
        u.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(fileUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication, // download / open externally
              );
            },
          )
        ],
      ),
      body: _isImage(fileUrl)
          // 🖼 IMAGE PREVIEW (INLINE)
          ? InteractiveViewer(
              child: Center(
                child: Image.network(
                  fileUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Text('Failed to load image'),
                ),
              ),
            )
          // 📄 EVERYTHING ELSE (PDF, DOCX, ETC) — INLINE WEBVIEW
          : Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text('Open Preview'),
                onPressed: () async {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.inAppWebView, // 👈 THIS IS THE FIX
                  );
                },
              ),
            ),
    );
  }
}

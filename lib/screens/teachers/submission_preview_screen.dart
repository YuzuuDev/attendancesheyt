import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SubmissionPreviewWidget extends StatelessWidget {
  final String fileUrl;

  const SubmissionPreviewWidget({required this.fileUrl, super.key});

  bool get isImage {
    final l = fileUrl.toLowerCase();
    return l.endsWith('.png') ||
        l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.webp');
  }

  bool get isPdf {
    return fileUrl.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PREVIEW AREA
        if (isImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fileUrl,
              height: 180,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, loading) =>
                  loading == null
                      ? child
                      : const LinearProgressIndicator(),
            ),
          )
        else if (isPdf)
          Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Text(
              "PDF file\nPreview available via Download",
              textAlign: TextAlign.center,
            ),
          )
        else
          const Text(
            "No preview available for this file type",
            style: TextStyle(color: Colors.grey),
          ),

        const SizedBox(height: 8),

        /// DOWNLOAD BUTTON (EXPLICIT)
        TextButton.icon(
          icon: const Icon(Icons.download),
          label: const Text("Download"),
          onPressed: () async {
            final uri = Uri.parse(fileUrl);
            final res = await http.get(uri);

            final dir = await getApplicationDocumentsDirectory();
            final file =
                File('${dir.path}/${uri.pathSegments.last}');
            await file.writeAsBytes(res.bodyBytes);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("File downloaded")),
            );
          },
        ),
      ],
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

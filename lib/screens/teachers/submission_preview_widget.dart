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

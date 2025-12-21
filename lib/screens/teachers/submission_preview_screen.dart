import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;

  bool _isImage(String url) {
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp');
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.fileUrl));
  }

  @override
  Widget build(BuildContext context) {
    /// IMAGE → DIRECT IN-APP PREVIEW
    if (_isImage(widget.fileUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.fileUrl,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    }

    /// EVERYTHING ELSE → IN-APP WEBVIEW (PDF, DOCX, ETC.)
    return SizedBox(
      height: 350,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(controller: _controller),
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

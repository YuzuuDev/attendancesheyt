import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _isImage(String url) =>
      url.endsWith('.png') ||
      url.endsWith('.jpg') ||
      url.endsWith('.jpeg') ||
      url.endsWith('.gif') ||
      url.endsWith('.webp');

  bool _isPdf(String url) => url.endsWith('.pdf');

  bool _isDoc(String url) =>
      url.endsWith('.doc') || url.endsWith('.docx');

  @override
  void initState() {
    super.initState();

    final uri = _isDoc(widget.fileUrl)
        ? Uri.parse(
            'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.fileUrl)}')
        : Uri.parse(widget.fileUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ⬇️ DOWNLOAD BUTTON (YOU ASKED FOR IT)
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final uri = Uri.parse(widget.fileUrl);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          ),
        ),

        /// 🖼 IMAGE → REAL INLINE PREVIEW
        if (_isImage(widget.fileUrl))
          Expanded(
            child: InteractiveViewer(
              child: Image.network(widget.fileUrl),
            ),
          )

        /// 📄 PDF / DOCX / ANYTHING ELSE → WEBVIEW
        else
          Expanded(
            child: WebViewWidget(controller: _controller),
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

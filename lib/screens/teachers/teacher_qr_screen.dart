import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class TeacherQRScreen extends StatefulWidget {
  final String classId;
  final String className;

  TeacherQRScreen({required this.classId, required this.className});

  @override
  State<TeacherQRScreen> createState() => _TeacherQRScreenState();
}

class _TeacherQRScreenState extends State<TeacherQRScreen> {
  late String qrCodeString;
  DateTime? startTime;
  final durationMinutes = 15; // QR valid for 15 mins

  @override
  void initState() {
    super.initState();
    _generateQR();
  }

  void _generateQR() {
    // Unique string: classId + uuid + timestamp
    qrCodeString =
        "${widget.classId}_${Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}";
    startTime = DateTime.now();
  }

  bool isQRValid() {
    if (startTime == null) return false;
    final diff = DateTime.now().difference(startTime!);
    return diff.inMinutes < durationMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR for ${widget.className}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isQRValid())
              QrImage(
                data: qrCodeString,
                version: QrVersions.auto,
                size: 250.0,
              )
            else
              Text("QR expired", style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQR,
              child: Text("Regenerate QR"),
            ),
          ],
        ),
      ),
    );
  }
}

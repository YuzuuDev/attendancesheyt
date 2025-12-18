import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../supabase_client.dart';

class StudentQRScanScreen extends StatefulWidget {
  const StudentQRScanScreen({super.key});

  @override
  State<StudentQRScanScreen> createState() => _StudentQRScanScreenState();
}

class _StudentQRScanScreenState extends State<StudentQRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  bool scanned = false;
  String? message;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _onScan(Barcode result) async {
    if (scanned) return;
    scanned = true;

    final qrData = result.code;
    if (qrData == null) {
      setState(() => message = "Invalid QR code");
      scanned = false;
      return;
    }

    final studentId =
        SupabaseClientInstance.supabase.auth.currentUser!.id;

    // QR FORMAT: classId-timestamp
    final parts = qrData.split('-');
    if (parts.length != 2) {
      setState(() => message = "Invalid QR format");
      scanned = false;
      return;
    }

    final classId = parts[0];
    final timestamp = int.tryParse(parts[1]);
    if (timestamp == null) {
      setState(() => message = "Invalid QR timestamp");
      scanned = false;
      return;
    }

    final qrTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    String status;
    final diffMinutes = now.difference(qrTime).inMinutes;

    if (diffMinutes <= 15) {
      status = "on-time";
    } else if (diffMinutes <= 30) {
      status = "late";
    } else {
      status = "absent";
    }

    try {
      // 🔹 Get latest active session
      final session = await SupabaseClientInstance.supabase
          .from('attendance_sessions')
          .select('id, end_time')
          .eq('class_id', classId)
          .order('start_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (session == null) {
        setState(() => message = "No active attendance session");
        scanned = false;
        return;
      }

      final sessionId = session['id'];
      final sessionEnd =
          DateTime.parse(session['end_time']);

      if (now.isAfter(sessionEnd.add(const Duration(minutes: 15)))) {
        status = "absent";
      }

      // 🔹 INSERT — rely on UNIQUE constraint
      await SupabaseClientInstance.supabase
          .from('attendance_records')
          .insert({
            'session_id': sessionId,
            'student_id': studentId,
            'status': status,
          });

      setState(() => message = "Attendance recorded: $status");
    } catch (e) {
      // 🔹 UNIQUE constraint violation lands here
      setState(() => message = "Already scanned");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Attendance QR")),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: (ctrl) {
                controller = ctrl;
                controller!.scannedDataStream.listen(_onScan);
              },
            ),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              scanned = false;
              setState(() => message = null);
            },
            child: const Text("Scan Again"),
          ),
        ],
      ),
    );
  }
}

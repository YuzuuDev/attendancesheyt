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
    if (scanned) return; // Prevent duplicate scans
    scanned = true;

    final code = result.code;
    if (code == null) {
      setState(() => message = "Invalid QR code");
      return;
    }

    final studentId = SupabaseClientInstance.supabase.auth.currentUser!.id;

    // Parse QR code (format: classId-timestamp)
    final parts = code.split('-');
    if (parts.length != 2) {
      setState(() => message = "QR code format invalid");
      return;
    }

    final classId = parts[0];
    final timestamp = int.tryParse(parts[1]);
    if (timestamp == null) {
      setState(() => message = "QR code timestamp invalid");
      return;
    }

    final qrTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    String status;
    final diff = now.difference(qrTime).inMinutes;
    if (diff <= 15) {
      status = "on-time";
    } else if (diff <= 30) {
      status = "late";
    } else {
      status = "absent";
    }

    try {
      // Get the latest session for this class
      final sessionResp = await SupabaseClientInstance.supabase
          .from('attendance_sessions')
          .select('id, end_time')
          .eq('class_id', classId)
          .order('start_time', ascending: false)
          .limit(1)
          .maybeSingle();

      final sessionId = sessionResp?['id'];
      final sessionEnd = DateTime.tryParse(sessionResp?['end_time'] ?? '');

      if (sessionId == null || sessionEnd == null) {
        setState(() => message = "Attendance session not found");
        return;
      }

      if (now.isAfter(sessionEnd.add(const Duration(minutes: 15)))) {
        status = "absent";
      }

      // Insert attendance record
      final insertResp = await SupabaseClientInstance.supabase
          .from('attendance_records')
          .insert({
            'session_id': sessionId,
            'student_id': studentId,
            'status': status,
          })
          .execute();

      if (insertResp.error != null) {
        setState(() => message =
            "Already scanned or error: ${insertResp.error!.message}");
        return;
      }

      setState(() => message = "Attendance recorded: $status");
    } catch (e) {
      setState(() => message = "Error recording attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController ctrl) {
                controller = ctrl;
                controller!.scannedDataStream.listen(_onScan);
              },
            ),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}

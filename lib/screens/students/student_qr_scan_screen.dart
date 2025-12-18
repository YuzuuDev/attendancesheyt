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
  
    final code = result.code;
    if (code == null) {
      setState(() => message = "Invalid QR code");
      scanned = false;
      return;
    }
  
    final studentId = SupabaseClientInstance.supabase.auth.currentUser!.id;
  
    final parts = code.split('|');
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
    final diff = now.difference(qrTime).inMinutes;
    if (diff <= 15) {
      status = "on-time";
    } else if (diff <= 30) {
      status = "late";
    } else {
      status = "absent";
    }
  
    try {
      final sessionResp = await SupabaseClientInstance.supabase
          .from('attendance_sessions')
          .select('id, end_time')
          .eq('class_id', classId)
          .order('start_time', ascending: false)
          .limit(1)
          .maybeSingle();
  
      if (sessionResp == null) {
        setState(() => message = "Session not found");
        scanned = false;
        return;
      }
  
      final sessionId = sessionResp['id'];
      final sessionEnd = DateTime.parse(sessionResp['end_time']);
  
      if (now.isAfter(sessionEnd)) {
        status = "absent";
      }
  
      final insert = await SupabaseClientInstance.supabase
          .from('attendance_records')
          .insert({
            'session_id': sessionId,
            'student_id': studentId,
            'status': status,
          })
          .select()
          .maybeSingle();
  
      if (insert == null) {
        setState(() => message = "Already scanned");
        return;
      }
  
      setState(() => message = "Attendance recorded: $status");
    } catch (e) {
      setState(() => message = "Error: $e");
      scanned = false;
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

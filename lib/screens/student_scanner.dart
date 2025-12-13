import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentScanner extends StatefulWidget {
  final String classId;
  StudentScanner({required this.classId});
  @override
  _StudentScannerState createState() => _StudentScannerState();
}

class _StudentScannerState extends State<StudentScanner> {
  final supabase = Supabase.instance.client;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      final student = supabase.auth.currentUser;
      final now = DateTime.now().toUtc();

      final session = await supabase
          .from('attendance_sessions')
          .select()
          .eq('qr_code', scanData.code)
          .single()
          .execute();

      if (session.error == null && session.data != null) {
        final startTime = DateTime.parse(session.data['start_time']);
        final endTime = DateTime.parse(session.data['end_time']);
        String status = 'present';
        if (now.isAfter(endTime.add(Duration(minutes: 30)))) status = 'absent';
        else if (now.isAfter(startTime.add(Duration(minutes: 15)))) status = 'late';

        await supabase.from('attendance_records').insert({
          'session_id': session.data['id'],
          'student_id': student!.id,
          'status': status,
        }).execute();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Attendance recorded: $status')));
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
    );
  }
}

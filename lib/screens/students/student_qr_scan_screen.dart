import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/class_service.dart';
import '../../supabase_client.dart';

class StudentQRScanScreen extends StatefulWidget {
  @override
  State<StudentQRScanScreen> createState() => _StudentQRScanScreenState();
}

class _StudentQRScanScreenState extends State<StudentQRScanScreen> {
  final AttendanceService attendanceService = AttendanceService();
  String? message;

  void _onDetect(String code) async {
    final studentId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final error = await attendanceService.scanQR(code, studentId);

    setState(() => message = error ?? "Attendance recorded successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              allowDuplicates: false,
              onDetect: (capture) {
                final code = capture.barcodes.first.rawValue;
                if (code != null) _onDetect(code);
              },
            ),
          ),
          if (message != null)
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(message!, style: TextStyle(fontSize: 16, color: Colors.green)),
            )
        ],
      ),
    );
  }
}

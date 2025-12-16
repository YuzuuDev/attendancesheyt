import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../services/class_service.dart';
import '../../supabase_client.dart';

class StudentQRScanScreen extends StatefulWidget {
  @override
  State<StudentQRScanScreen> createState() => _StudentQRScanScreenState();
}

class _StudentQRScanScreenState extends State<StudentQRScanScreen> {
  final AttendanceService attendanceService = AttendanceService();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? message;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      if (code != null) {
        final studentId = SupabaseClientInstance.supabase.auth.currentUser!.id;
        final error = await attendanceService.scanQR(code, studentId);

        setState(() => message = error ?? "Attendance recorded successfully");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (message != null)
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                message!,
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}

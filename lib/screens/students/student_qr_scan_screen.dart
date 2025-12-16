import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
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
  bool scanned = false;

  void _onScan(Barcode result) async {
    if (scanned) return; // Prevent duplicates
    scanned = true;

    final code = result.code;
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
            child: QRScanner(
              key: qrKey,
              formats: [BarcodeFormat.qrCode],
              onScannerCreated: (controller) {
                controller.start();
                controller.scannedDataStream.listen(_onScan);
              },
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

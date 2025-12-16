import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import '../../services/class_service.dart';
import '../../supabase_client.dart';

class StudentQRScanScreen extends StatefulWidget {
  @override
  State<StudentQRScanScreen> createState() => _StudentQRScanScreenState();
}

class _StudentQRScanScreenState extends State<StudentQRScanScreen> {
  final AttendanceService attendanceService = AttendanceService();
  bool isScanning = true;
  String? message;

  void _onQRViewCreated(String code) async {
    if (!isScanning) return;
    setState(() => isScanning = false);

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
            child: isScanning
                ? QRBarScannerCamera(
                    onError: (context, error) => Text(error.toString()),
                    qrCodeCallback: _onQRViewCreated,
                  )
                : Center(child: Text(message ?? "Done")),
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

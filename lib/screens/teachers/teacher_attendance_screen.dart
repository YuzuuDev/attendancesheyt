import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/class_service.dart';
import '../../supabase_client.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;

  TeacherAttendanceScreen({required this.classId, required this.className});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final AttendanceService attendanceService = AttendanceService();
  String? qrCode;
  List<Map<String, dynamic>> scannedStudents = [];
  bool isLoading = false;

  void _startSession() async {
    setState(() => isLoading = true);

    final teacherId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final code = await attendanceService.startSession(widget.classId, teacherId, 15);

    setState(() {
      qrCode = code;
      isLoading = false;
    });

    _refreshScans();
  }

  void _refreshScans() async {
    if (qrCode == null) return;

    // fetch latest session by QR code
    final session = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .select('*')
        .eq('qr_code', qrCode)
        .maybeSingle();

    if (session != null) {
      final records = await attendanceService.getSessionAttendance(session['id']);
      setState(() => scannedStudents = records);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance - ${widget.className}")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (qrCode == null)
              ElevatedButton(
                onPressed: _startSession,
                child: isLoading ? CircularProgressIndicator() : Text("Start Attendance"),
              ),
            if (qrCode != null) ...[
              QrImage(data: qrCode!, size: 200),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshScans,
                child: Text("Refresh Scans"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: scannedStudents.length,
                  itemBuilder: (_, index) {
                    final s = scannedStudents[index];
                    final name = s['profiles']?['full_name'] ?? 'Unknown';
                    final status = s['status'];
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(status),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../supabase_client.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;

  const TeacherAttendanceScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  List<Map<String, dynamic>> scannedStudents = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadScannedStudents();
    // auto-refresh every 5s
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadScannedStudents());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadScannedStudents() async {
    try {
      // fetch attendance records for this class
      final records = await SupabaseClientInstance.supabase
          .from('attendance_records')
          .select('student_id, status, scanned_at, profiles(full_name)')
          .eq('session_id', widget.classId); // use actual session id if needed

      setState(() {
        scannedStudents = List<Map<String, dynamic>>.from(records);
      });
    } catch (e) {
      debugPrint("Error fetching scanned students: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance - ${widget.className}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: scannedStudents.isEmpty
                  ? const Center(child: Text("No students have scanned yet"))
                  : ListView.builder(
                      itemCount: scannedStudents.length,
                      itemBuilder: (_, index) {
                        final student = scannedStudents[index];
                        final profile = student['profiles'];
                        return ListTile(
                          title: Text(profile?['full_name'] ?? student['student_id']),
                          subtitle: Text(student['status'] ?? 'unknown'),
                          trailing: Text(student['scanned_at'] ?? ''),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}





/*import 'package:flutter/material.dart';
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
}*/

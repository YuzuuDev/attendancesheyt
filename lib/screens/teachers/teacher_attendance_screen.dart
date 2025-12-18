import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../supabase_client.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final String classId;
  final String className;

  TeacherAttendanceScreen({required this.classId, required this.className});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String? qrCode;
  String sessionId = '';
  List<Map<String, dynamic>> scannedStudents = [];
  Timer? timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() => isLoading = true);

    final teacherId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final now = DateTime.now();
    final endTime = now.add(const Duration(minutes: 15));

    qrCode = "${widget.classId}|${now.millisecondsSinceEpoch}";

    final response = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .insert({
          'class_id': widget.classId,
          'teacher_id': teacherId,
          'start_time': now.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'qr_code': qrCode,
        })
        .select('id')
        .maybeSingle();

    sessionId = response?['id'] ?? '';

    // Start live refresh every 5 seconds
    timer = Timer.periodic(Duration(seconds: 5), (_) => _loadScannedStudents());

    setState(() => isLoading = false);
  }

  Future<void> _loadScannedStudents() async {
    if (sessionId.isEmpty) return;

    final records = await SupabaseClientInstance.supabase
        .from('attendance_records')
        .select('student_id, status, scanned_at')
        .eq('session_id', sessionId);

    setState(() {
      scannedStudents = List<Map<String, dynamic>>.from(records);
    });
  }

  String _countdown() {
    if (qrCode == null || sessionId.isEmpty) return '';
    return 'Live updates every 5s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance - ${widget.className}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (qrCode != null) ...[
              QrImage(data: qrCode!, version: QrVersions.auto, size: 200),
              const SizedBox(height: 10),
              Text("Scan this QR code to mark attendance"),
              const SizedBox(height: 5),
              Text(_countdown()),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _loadScannedStudents,
              child: Text("Refresh Scanned Students"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: scannedStudents.isEmpty
                  ? const Center(child: Text("No students scanned yet"))
                  : ListView.builder(
                      itemCount: scannedStudents.length,
                      itemBuilder: (_, index) {
                        final s = scannedStudents[index];
                        return ListTile(
                          title: Text(s['student_id']), // raw student_id
                          subtitle: Text(s['status'] ?? 'unknown'),
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

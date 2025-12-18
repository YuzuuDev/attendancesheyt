import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/attendance_service.dart';
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

    final session = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .select('*')
        .eq('qr_code', qrCode)
        .order('start_time', ascending: false)
        .maybeSingle();

    if (session != null) {
      final sessionId = session['id'];

      // fetch attendance records first
      final records = await SupabaseClientInstance.supabase
          .from('attendance_records')
          .select('student_id, status, scanned_at')
          .eq('session_id', sessionId);

      final List<Map<String, dynamic>> tempList = [];

      // manually fetch profiles
      for (var record in records) {
        final profile = await SupabaseClientInstance.supabase
            .from('profiles')
            .select('full_name')
            .eq('id', record['student_id'])
            .maybeSingle();

        tempList.add({
          ...record,
          'profiles': profile,
        });
      }

      setState(() {
        scannedStudents = tempList;
      });
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
              const SizedBox(height: 20),
              Expanded(
                child: scannedStudents.isEmpty
                    ? const Center(child: Text("No students scanned yet"))
                    : ListView.builder(
                        itemCount: scannedStudents.length,
                        itemBuilder: (_, index) {
                          final s = scannedStudents[index];
                          final name = s['profiles']?['full_name'] ?? 'Unknown';
                          final status = s['status'] ?? 'unknown';
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

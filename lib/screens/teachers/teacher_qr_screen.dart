import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../supabase_client.dart';

class TeacherQRScreen extends StatefulWidget {
  final String classId;
  final String className;

  const TeacherQRScreen({required this.classId, required this.className, super.key});

  @override
  State<TeacherQRScreen> createState() => _TeacherQRScreenState();
}

class _TeacherQRScreenState extends State<TeacherQRScreen> {
  String? qrCodeString;
  String sessionId = '';
  DateTime? startTime;
  DateTime? endTime;
  List<Map<String, dynamic>> scannedStudents = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _createSession() async {
    startTime = DateTime.now();
    endTime = startTime!.add(const Duration(minutes: 15));

    qrCodeString = "${widget.classId}|${startTime!.millisecondsSinceEpoch}";

    final response = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .insert({
          'class_id': widget.classId,
          'teacher_id': SupabaseClientInstance.supabase.auth.currentUser!.id,
          'start_time': startTime!.toIso8601String(),
          'end_time': endTime!.toIso8601String(),
          'qr_code': qrCodeString,
        })
        .select('id')
        .maybeSingle();

    sessionId = response?['id'] ?? '';

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadScannedStudents(),
    );

    setState(() {});
  }

  Future<void> _loadScannedStudents() async {
    if (sessionId.isEmpty) return;

    // Step 1: fetch attendance records for the session
    final records = await SupabaseClientInstance.supabase
        .from('attendance_records')
        .select('student_id, status, scanned_at')
        .eq('session_id', sessionId);

    final List<Map<String, dynamic>> tempList = [];

    // Step 2: manually fetch profiles for each student
    for (var record in records) {
      final profile = await SupabaseClientInstance.supabase
          .from('profiles')
          .select('full_name')
          .eq('id', record['student_id'])
          .maybeSingle();

      tempList.add({
        ...record,
        'profiles': profile, // attach profile manually
      });
    }

    setState(() {
      scannedStudents = tempList;
    });
  }

  String _countdown() {
    if (endTime == null) return '';
    final diff = endTime!.difference(DateTime.now());
    if (diff.isNegative) return "Session expired";
    final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance - ${widget.className}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (qrCodeString != null)
              Column(
                children: [
                  QrImageView(
                    data: qrCodeString!,
                    version: QrVersions.auto,
                    size: 250,
                    gapless: false,
                  ),
                  const SizedBox(height: 10),
                  const Text("Scan this QR code to mark attendance"),
                  const SizedBox(height: 10),
                  Text("Countdown: ${_countdown()}"),
                  const SizedBox(height: 20),
                ],
              )
            else
              const CircularProgressIndicator(),
            ElevatedButton(
              onPressed: _loadScannedStudents,
              child: const Text("Refresh Scanned Students"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: scannedStudents.isEmpty
                  ? const Center(child: Text("No students scanned yet"))
                  : ListView.builder(
                      itemCount: scannedStudents.length,
                      itemBuilder: (_, index) {
                        final student = scannedStudents[index];
                        final profile = student['profiles'];
                        return ListTile(
                          title: Text(profile?['full_name'] ?? 'Unknown'),
                          subtitle: Text(student['status'] ?? 'unknown'),
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

/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../supabase_client.dart';

class TeacherQRScreen extends StatefulWidget {
  final String classId;
  final String className;

  const TeacherQRScreen({required this.classId, required this.className, super.key});

  @override
  State<TeacherQRScreen> createState() => _TeacherQRScreenState();
}

class _TeacherQRScreenState extends State<TeacherQRScreen> {
  String? qrCodeString;
  String sessionId = '';
  DateTime? startTime;
  DateTime? endTime;
  List<Map<String, dynamic>> scannedStudents = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _createSession() async {
    startTime = DateTime.now();
    endTime = startTime!.add(const Duration(minutes: 15));
  
    qrCodeString = "${widget.classId}|${startTime!.millisecondsSinceEpoch}";
  
    final response = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .insert({
          'class_id': widget.classId,
          'teacher_id': SupabaseClientInstance.supabase.auth.currentUser!.id,
          'start_time': startTime!.toIso8601String(),
          'end_time': endTime!.toIso8601String(),
          'qr_code': qrCodeString,
        })
        .select('id')
        .maybeSingle();
  
    sessionId = response?['id'] ?? '';
  
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadScannedStudents(),
    );
  
    setState(() {});
  }

  Future<void> _loadScannedStudents() async {
    if (sessionId.isEmpty) return;

    final response = await SupabaseClientInstance.supabase
        .from('attendance_records')
        .select('student_id, scanned_at, status, profiles(full_name)')
        .eq('session_id', sessionId);

    setState(() {
      scannedStudents = List<Map<String, dynamic>>.from(response);
    });
  }

  String _countdown() {
    if (endTime == null) return '';
    final diff = endTime!.difference(DateTime.now());
    if (diff.isNegative) return "Session expired";
    final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance - ${widget.className}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (qrCodeString != null)
              Column(
                children: [
                  QrImageView(
                    data: qrCodeString!,
                    version: QrVersions.auto,
                    size: 250,
                    gapless: false,
                  ),
                  const SizedBox(height: 10),
                  const Text("Scan this QR code to mark attendance"),
                  const SizedBox(height: 10),
                  Text("Countdown: ${_countdown()}"),
                  const SizedBox(height: 20),
                ],
              )
            else
              const CircularProgressIndicator(),
            ElevatedButton(
              onPressed: _loadScannedStudents,
              child: const Text("Refresh Scanned Students"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: scannedStudents.isEmpty
                  ? const Center(child: Text("No students scanned yet"))
                  : ListView.builder(
                      itemCount: scannedStudents.length,
                      itemBuilder: (_, index) {
                        final student = scannedStudents[index];
                        final profile = student['profiles'];
                        return ListTile(
                          title: Text(profile?['full_name'] ?? 'Unknown'),
                          subtitle: Text(student['status']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}*/

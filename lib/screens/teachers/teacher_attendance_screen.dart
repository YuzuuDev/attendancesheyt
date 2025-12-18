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
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  List<Map<String, dynamic>> scannedStudents = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadScannedStudents();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadScannedStudents());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadScannedStudents() async {
    try {
      // Fetch attendance records for this class/session
      final records = await SupabaseClientInstance.supabase
          .from('attendance_records')
          .select('student_id, status, scanned_at, profiles(full_name)')
          .eq('session_id', widget.classId); // replace with actual sessionId if needed

      setState(() {
        scannedStudents = List<Map<String, dynamic>>.from(records);
      });
    } catch (e) {
      debugPrint("Error fetching scanned students: $e");
    }
  }

  Map<String, int> _summarizeAttendance() {
    int onTime = 0;
    int late = 0;
    int absent = 0;

    for (var student in scannedStudents) {
      switch (student['status']) {
        case 'on_time':
          onTime++;
          break;
        case 'late':
          late++;
          break;
        case 'absent':
          absent++;
          break;
      }
    }

    return {
      'on_time': onTime,
      'late': late,
      'absent': absent,
      'total': scannedStudents.length,
    };
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'on_time':
        return Colors.green.shade300;
      case 'late':
        return Colors.yellow.shade300;
      case 'absent':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summarizeAttendance();

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance - ${widget.className}"),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Summary Card
            Card(
              color: Colors.green.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem("On-time", summary['on_time']!, Colors.green.shade400),
                    _buildSummaryItem("Late", summary['late']!, Colors.yellow.shade700),
                    _buildSummaryItem("Absent", summary['absent']!, Colors.red.shade400),
                    _buildSummaryItem("Total", summary['total']!, Colors.green.shade600),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ List of students
            Expanded(
              child: scannedStudents.isEmpty
                  ? Center(
                      child: Text(
                        "No students have scanned yet",
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: scannedStudents.length,
                      itemBuilder: (_, index) {
                        final student = scannedStudents[index];
                        final profile = student['profiles'];
                        final status = student['status'] ?? 'unknown';

                        return Card(
                          color: _statusColor(status),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              profile?['full_name'] ?? student['student_id'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              status.replaceAll('_', ' ').toUpperCase(),
                            ),
                            trailing: Text(
                              student['scanned_at'] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/*import 'dart:async';
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
}*/

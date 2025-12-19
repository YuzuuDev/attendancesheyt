import 'package:flutter/material.dart';
import '../../supabase_client.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String classId;
  final String className;

  const AttendanceHistoryScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool isLoading = true;
  String? error;

  /// FINAL HISTORY STRUCTURE:
  /// [
  ///   {
  ///     session: {...},
  ///     records: [...]
  ///   }
  /// ]
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      /// 1️⃣ GET ALL SESSIONS FOR THIS CLASS
      final sessions = await SupabaseClientInstance.supabase
          .from('attendance_sessions')
          .select('id, start_time, end_time')
          .eq('class_id', widget.classId)
          .order('start_time', ascending: false);

      List<Map<String, dynamic>> temp = [];

      /// 2️⃣ FOR EACH SESSION → GET WHO ATTENDED
      for (final session in sessions) {
        final records = await SupabaseClientInstance.supabase
            .from('attendance_records')
            .select('status, scanned_at, profiles(full_name)')
            .eq('session_id', session['id']);

        temp.add({
          'session': session,
          'records': records,
        });
      }

      setState(() {
        history = temp;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load attendance history: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDateTime(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'on_time':
        return Colors.green.shade100;
      case 'late':
        return Colors.yellow.shade100;
      case 'absent':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance History - ${widget.className}"),
        backgroundColor: Colors.green[400],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : history.isEmpty
                  ? const Center(child: Text("No attendance history found"))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (_, index) {
                        final session = history[index]['session'];
                        final records =
                            List<Map<String, dynamic>>.from(
                                history[index]['records']);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ExpansionTile(
                            title: Text(
                              "Session: ${_formatDateTime(session['start_time'])}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Ended: ${_formatDateTime(session['end_time'])}",
                            ),
                            children: records.isEmpty
                                ? const [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                          "No students scanned for this session"),
                                    )
                                  ]
                                : records.map((r) {
                                    final profile = r['profiles'];
                                    final status = r['status'] ?? 'unknown';
                                    final scannedAt =
                                        r['scanned_at'] ?? '';

                                    return Card(
                                      color: _statusColor(status),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: ListTile(
                                        title: Text(
                                          profile?['full_name'] ??
                                              'Unknown Student',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          status
                                              .replaceAll('_', ' ')
                                              .toUpperCase(),
                                        ),
                                        trailing: Text(
                                          scannedAt != ''
                                              ? DateTime.parse(scannedAt)
                                                  .toLocal()
                                                  .toIso8601String()
                                                  .substring(11, 19)
                                              : '',
                                          style:
                                              const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        );
                      },
                    ),
    );
  }
}

/*import 'package:flutter/material.dart';
import '../../supabase_client.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String classId;
  final String className;

  const AttendanceHistoryScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await SupabaseClientInstance.supabase
          .from('attendance_sessions')
          .select('id, start_time, end_time')
          .eq('class_id', widget.classId)
          .order('start_time', ascending: false) as List<dynamic>;

      setState(() {
        sessions = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      setState(() {
        error = "Failed to load sessions: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadAttendance(String sessionId) async {
    try {
      final records = await SupabaseClientInstance.supabase
          .from('attendance_records')
          .select('student_id, status, scanned_at, profiles(full_name)')
          .eq('session_id', sessionId) as List<dynamic>;

      return List<Map<String, dynamic>>.from(records);
    } catch (e) {
      debugPrint("Error loading attendance: $e");
      return [];
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance History - ${widget.className}"),
        backgroundColor: Colors.green[400],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : sessions.isEmpty
                  ? const Center(child: Text("No attendance sessions yet"))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (_, index) {
                        final session = sessions[index];
                        final sessionId = session['id'];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: ExpansionTile(
                            title: Text(
                              "Session on ${_formatTime(session['start_time'])}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "Ended at: ${_formatTime(session['end_time'])}"),
                            children: [
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _loadAttendance(sessionId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final records = snapshot.data ?? [];

                                  if (records.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text("No students attended this session"),
                                    );
                                  }

                                  return Column(
                                    children: records.map((student) {
                                      final profile = student['profiles'];
                                      final status = student['status'] ?? 'unknown';
                                      final scannedAt = student['scanned_at'] ?? '';

                                      Color color;
                                      switch (status) {
                                        case 'on_time':
                                          color = Colors.green.shade100;
                                          break;
                                        case 'late':
                                          color = Colors.yellow.shade100;
                                          break;
                                        case 'absent':
                                          color = Colors.red.shade100;
                                          break;
                                        default:
                                          color = Colors.grey.shade100;
                                      }

                                      return Card(
                                        color: color,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 16),
                                        child: ListTile(
                                          title: Text(
                                              profile?['full_name'] ??
                                                  student['student_id'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(status.toUpperCase()),
                                          trailing: Text(
                                            scannedAt != ''
                                                ? DateTime.parse(scannedAt)
                                                    .toLocal()
                                                    .toIso8601String()
                                                    .substring(11, 19)
                                                : '',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}*/

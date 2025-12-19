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
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> sessions = [];
  Map<String, List<Map<String, dynamic>>> recordsBySession = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final supabase = SupabaseClientInstance.supabase;
  
    // 1️⃣ Get sessions
    final sessionRes = await supabase
        .from('attendance_sessions')
        .select('id, start_time, end_time')
        .eq('class_id', widget.classId)
        .order('start_time', ascending: false);
  
    if (sessionRes.isEmpty) {
      setState(() {
        sessions = [];
        recordsBySession = {};
        loading = false;
      });
      return;
    }
  
    // 2️⃣ Get records WITH profiles
    final sessionIds = sessionRes.map((s) => s['id']).toList();
    final sessionIdsStr = sessionIds.map((id) => "'$id'").join(',');
  
    final recordRes = await supabase
        .from('attendance_records')
        .select('session_id, status, scanned_at, profiles(full_name)')
        .filter('session_id', 'in', '($sessionIdsStr)'); // ✅ Correct syntax
  
    // 3️⃣ Group records by session_id
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final r in recordRes) {
      grouped.putIfAbsent(r['session_id'], () => []);
      grouped[r['session_id']]!.add(r);
    }
  
    setState(() {
      sessions = List<Map<String, dynamic>>.from(sessionRes);
      recordsBySession = grouped;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance – ${widget.className}"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
              ? const Center(child: Text("No attendance history"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (_, index) {
                    final s = sessions[index];
                    final start = DateTime.parse(s['start_time']).toLocal();
                    final records = recordsBySession[s['id']] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(
                          "${start.year}-${start.month}-${start.day}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("${records.length} attended"),
                        children: records.isEmpty
                            ? [
                                const ListTile(
                                  title: Text("No scans"),
                                )
                              ]
                            : records.map((r) {
                                final name =
                                    r['profiles']?['full_name'] ?? 'Unknown';
                                final status = r['status'];

                                Color color = Colors.grey.shade200;
                                if (status == 'on_time') color = Colors.green.shade200;
                                if (status == 'late') color = Colors.orange.shade200;
                                if (status == 'absent') color = Colors.red.shade200;

                                return Container(
                                  color: color,
                                  child: ListTile(
                                    title: Text(name),
                                    subtitle: Text(status.toUpperCase()),
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

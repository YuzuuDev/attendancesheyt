import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../services/auth_service.dart';
import '../../supabase_client.dart';
import '../login_screen.dart';
import 'create_class_screen.dart';
import 'teacher_qr_screen.dart';
import 'attendance_history_screen.dart';
import 'teacher_assignments_screen.dart';
import 'participation_screen.dart';

// UI
import '../../ui/widgets/primary_button.dart';

class TeacherDashboard extends StatefulWidget {
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final ClassService classService = ClassService();
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() async {
    final teacherId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final result = await classService.getTeacherClasses(teacherId);
    setState(() {
      classes = result;
      isLoading = false;
    });
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Log Out"),
        content: const Text("Do you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _showStudents(String classId, String className) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    final students = await classService.getStudents(classId);
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text("Students in $className"),
        content: SizedBox(
          width: double.maxFinite,
          child: students.isEmpty
              ? const Text("No students enrolled")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (_, index) {
                    final profile = students[index]['profiles'];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.green),
                      title: Text(profile?['full_name'] ?? 'Unknown'),
                      subtitle: Text(profile?['role'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAttendanceHistory(String classId, String className) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    final sessions = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .select('id, start_time, end_time')
        .eq('class_id', classId)
        .order('start_time', ascending: false);

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text("Attendance History - $className"),
        content: SizedBox(
          width: double.maxFinite,
          child: sessions.isEmpty
              ? const Text("No attendance records yet")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (_, sIndex) {
                    final session = sessions[sIndex];
                    final start = DateTime.parse(session['start_time']).toLocal();
                    final end = DateTime.parse(session['end_time']).toLocal();

                    return FutureBuilder(
                      future: SupabaseClientInstance.supabase
                          .from('attendance_records')
                          .select(
                              'student_id, status, scanned_at, profiles(full_name)')
                          .eq('session_id', session['id']),
                      builder: (_, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final records =
                            List<Map<String, dynamic>>.from(snapshot.data);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              "${start.toIso8601String().substring(0, 10)} | "
                              "${start.hour}:${start.minute.toString().padLeft(2, '0')} - "
                              "${end.hour}:${end.minute.toString().padLeft(2, '0')}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: records.isEmpty
                                ? const [
                                    ListTile(
                                        title:
                                            Text("No students scanned"))
                                  ]
                                : records.map((r) {
                                    final profile = r['profiles'];
                                    final status = r['status'] ?? 'unknown';
                                    Color bg;
                                    switch (status) {
                                      case 'on_time':
                                        bg = Colors.green.shade100;
                                        break;
                                      case 'late':
                                        bg = Colors.yellow.shade100;
                                        break;
                                      case 'absent':
                                        bg = Colors.red.shade100;
                                        break;
                                      default:
                                        bg = Colors.grey.shade100;
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: bg,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                            profile?['full_name'] ??
                                                r['student_id']),
                                        subtitle: Text(status
                                            .replaceAll('_', ' ')
                                            .toUpperCase()),
                                        trailing: Text(r['scanned_at'] != null
                                            ? DateTime.parse(
                                                    r['scanned_at'])
                                                .toLocal()
                                                .toIso8601String()
                                                .substring(11, 19)
                                            : ''),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PrimaryButton(
              text: "Create Class",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateClassScreen()),
                ).then((_) => _loadClasses());
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: classes.isEmpty
                  ? const Center(child: Text("No classes"))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, index) {
                        final cls = classes[index];

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin:
                              const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green
                                    .withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                cls['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("Code: ${cls['code']}"),
                              const SizedBox(height: 14),

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  PrimaryButton(
                                    text: "View Students",
                                    onTap: () => _showStudents(
                                        cls['id'], cls['name']),
                                  ),
                                  const SizedBox(height: 8),
                                  PrimaryButton(
                                    text: "Start Attendance",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TeacherQRScreen(
                                            classId: cls['id'],
                                            className: cls['name'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  PrimaryButton(
                                    text: "Attendance History",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AttendanceHistoryScreen(
                                            classId: cls['id'],
                                            className: cls['name'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  PrimaryButton(
                                    text: "Assignments",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TeacherAssignmentsScreen(
                                            classId: cls['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  /// PARTICIPATION (VISUALLY DISTINCT, LOGIC SAME)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.orange.shade400,
                                      padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ParticipationScreen(
                                            classId: cls['id'],
                                            className: cls['name'],
                                          ),
                                        ),
                                      );
                                    },
                                    child:
                                        const Text("Participation"),
                                  ),
                                ],
                              ),
                            ],
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
}

/*import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../services/auth_service.dart';
import '../../supabase_client.dart';
import '../login_screen.dart';
import 'create_class_screen.dart';
import 'teacher_qr_screen.dart';
import 'attendance_history_screen.dart';
import 'teacher_assignments_screen.dart';
import 'participation_screen.dart'; 


class TeacherDashboard extends StatefulWidget {
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final ClassService classService = ClassService();
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() async {
    final teacherId = SupabaseClientInstance.supabase.auth.currentUser!.id;
    final result = await classService.getTeacherClasses(teacherId);
    setState(() {
      classes = result;
      isLoading = false;
    });
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Do you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _showStudents(String classId, String className) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    final students = await classService.getStudents(classId);
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Students in $className"),
        content: SizedBox(
          width: double.maxFinite,
          child: students.isEmpty
              ? const Text("No students enrolled")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (_, index) {
                    final profile = students[index]['profiles'];
                    return ListTile(
                      title: Text(profile?['full_name'] ?? 'Unknown'),
                      subtitle: Text(profile?['role'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAttendanceHistory(String classId, String className) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    final sessions = await SupabaseClientInstance.supabase
        .from('attendance_sessions')
        .select('id, start_time, end_time')
        .eq('class_id', classId)
        .order('start_time', ascending: false);

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Attendance History - $className"),
        content: SizedBox(
          width: double.maxFinite,
          child: sessions.isEmpty
              ? const Text("No attendance records yet")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (_, sIndex) {
                    final session = sessions[sIndex];
                    final start = DateTime.parse(session['start_time']).toLocal();
                    final end = DateTime.parse(session['end_time']).toLocal();

                    return FutureBuilder(
                      future: SupabaseClientInstance.supabase
                          .from('attendance_records')
                          .select('student_id, status, scanned_at, profiles(full_name)')
                          .eq('session_id', session['id']),
                      builder: (_, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final records = List<Map<String, dynamic>>.from(snapshot.data);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ExpansionTile(
                            title: Text(
                              "${start.toIso8601String().substring(0, 10)} | ${start.hour}:${start.minute.toString().padLeft(2,'0')} - ${end.hour}:${end.minute.toString().padLeft(2,'0')}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: records.isEmpty
                                ? [const ListTile(title: Text("No students scanned"))]
                                : records.map((r) {
                                    final profile = r['profiles'];
                                    final status = r['status'] ?? 'unknown';
                                    Color bg;
                                    switch (status) {
                                      case 'on_time':
                                        bg = Colors.green.shade200;
                                        break;
                                      case 'late':
                                        bg = Colors.yellow.shade200;
                                        break;
                                      case 'absent':
                                        bg = Colors.red.shade200;
                                        break;
                                      default:
                                        bg = Colors.grey.shade100;
                                    }
                                    return Container(
                                      color: bg,
                                      child: ListTile(
                                        title: Text(profile?['full_name'] ?? r['student_id']),
                                        subtitle: Text(status.replaceAll('_', ' ').toUpperCase()),
                                        trailing: Text(r['scanned_at'] != null
                                            ? DateTime.parse(r['scanned_at']).toLocal()
                                                .toIso8601String().substring(11,19)
                                            : ''),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateClassScreen()),
                ).then((_) => _loadClasses());
              },
              child: const Text("Create Class"),
            ),
            const SizedBox(height: 20),
          
            Expanded(
              child: classes.isEmpty
                  ? const Center(child: Text("No classes"))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, index) {
                        final cls = classes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cls['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("Code: ${cls['code']}"),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _showStudents(cls['id'], cls['name']),
                                      child: const Text("View Students"),
                                    ),


                                    const SizedBox(height: 6),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TeacherQRScreen(
                                              classId: cls['id'],
                                              className: cls['name'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Start Attendance"),
                                    ),
                                    const SizedBox(height: 6),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AttendanceHistoryScreen(
                                              classId: cls['id'],
                                              className: cls['name'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Attendance History"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TeacherAssignmentsScreen(
                                              classId: cls['id'],
                                              //className: cls['name'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text("Assignments"),
                                    ),
                                    // 🔥 THIS IS THE PARTICIPATION ACCESS
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                      child: const Text("Participation"),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ParticipationScreen(
                                              classId: cls['id'],
                                              className: cls['name'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
}*/


import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../services/participation_service.dart';
import '../../supabase_client.dart';
import 'student_class_screen.dart';
import 'join_class_screen.dart';

class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ClassService classService = ClassService();
  final ParticipationService participationService = ParticipationService();

  List<Map<String, dynamic>> classes = [];
  int points = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = SupabaseClientInstance.supabase.auth.currentUser!.id;
    classes = await classService.getStudentClasses(id);
    points = await participationService.getStudentPoints(id);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ GLOBAL PARTICIPATION (ONCE)
            Card(
              child: ListTile(
                title: const Text("Participation Points"),
                trailing: Text(
                  points.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JoinClassScreen()),
                ).then((_) => _load());
              },
              child: const Text("Join Class"),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: classes.isEmpty
                  ? const Center(child: Text("No classes joined"))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, i) {
                        final c = classes[i];
                        return Card(
                          child: ListTile(
                            title: Text(c['name']),
                            subtitle: Text("Code: ${c['code']}"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentClassScreen(
                                    classId: c['id'],
                                    className: c['name'],
                                  ),
                                ),
                              );
                            },
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
import 'join_class_screen.dart';
import '../login_screen.dart';
import 'student_qr_scan_screen.dart';
import 'student_assignments_screen.dart';
import 'student_class_screen.dart'; // ✅ CLASS HOME
//import 'student_participation_widget.dart';


class StudentDashboard extends StatefulWidget {
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ClassService classService = ClassService();
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final studentId =
        SupabaseClientInstance.supabase.auth.currentUser!.id;

    final result = await classService.getStudentClasses(studentId);
    setState(() {
      classes = result;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.green[400],
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
            // ✅ JOIN CLASS ONLY
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Join Class"),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JoinClassScreen()),
                );
                _loadClasses();
              },
            ),
            const SizedBox(height: 16),

            // ✅ CLASS LIST
            Expanded(
              child: classes.isEmpty
                  ? const Center(child: Text("No classes joined"))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (_, index) {
                        final cls = classes[index]['classes'];
                        final classId = classes[index]['class_id'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.class_),
                            title: Text(
                              cls['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Code: ${cls['code']}"),

                            // 🔥 THIS IS THE ACCESS POINT
                            // TAP CLASS → CLASS HOME
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentClassScreen(
                                    classId: classId,
                                    className: cls['name'],
                                  ),
                                ),
                              );
                            },

                            // OPTIONAL QUICK ACTIONS (still class-locked)
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.assignment),
                                  tooltip: "Assignments",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            StudentAssignmentsScreen(
                                          classId: classId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  tooltip: "Scan Attendance",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            StudentQRScanScreen(
                                          classId: classId,
                                        ),
                                      ),
                                    );
                                  },
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

import 'package:flutter/material.dart';
import '../../supabase_client.dart';
import '../../services/participation_service.dart';
import 'student_assignments_screen.dart';
import 'student_qr_scan_screen.dart';

class StudentClassScreen extends StatefulWidget {
  final String classId;
  final String className;

  const StudentClassScreen({
    required this.classId,
    required this.className,
    super.key,
  });

  @override
  State<StudentClassScreen> createState() => _StudentClassScreenState();
}

class _StudentClassScreenState extends State<StudentClassScreen> {
  final ParticipationService participationService = ParticipationService();
  int points = 0;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final studentId =
        SupabaseClientInstance.supabase.auth.currentUser!.id;
    points = await participationService.getStudentPoints(studentId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🟢 PARTICIPATION POINTS
            Card(
              child: ListTile(
                title: const Text("Participation Points"),
                trailing: Text(
                  points.toString(),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📷 SCAN QR (CLASS-LOCKED)
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan Attendance QR"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StudentQRScanScreen(classId: widget.classId),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // 📄 ASSIGNMENTS
            ElevatedButton(
              child: const Text("View Assignments"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentAssignmentsScreen(
                      classId: widget.classId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

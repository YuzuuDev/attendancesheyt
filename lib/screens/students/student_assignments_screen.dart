import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';
import 'recitation_screen.dart'; // ✅ ADD THIS

class StudentAssignmentsScreen extends StatefulWidget {
  final String classId;

  const StudentAssignmentsScreen({
    super.key,
    required this.classId,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen> {
  final AssignmentService _service = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final res = await _service.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text('No assignments yet'))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final a = assignments[index];
                    final type = a['assignment_type']; // ✅ READ TYPE

                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: ListTile(
                        title: Text(
                          a['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// 🔽 SUBTITLE UNCHANGED
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a['description'] != null &&
                                a['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(a['description']),
                              ),
                            const SizedBox(height: 6),

                            /// ✅ SUBMISSION STATUS (ACTIVITY ONLY)
                            if (type == 'activity')
                              FutureBuilder<Map<String, dynamic>?>(
                                future: _service.getMySubmission(a['id']),
                                builder: (_, snap) {
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                      "Checking submission...",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }

                                  if (!snap.hasData || snap.data == null) {
                                    return const Text(
                                      "❌ Not submitted",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                    );
                                  }

                                  final sub = snap.data!;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "✅ Submitted",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (sub['grade'] != null)
                                        Text(
                                          "Grade: ${sub['grade']}",
                                          style:
                                              const TextStyle(fontSize: 12),
                                        ),
                                      if (sub['feedback'] != null &&
                                          sub['feedback']
                                              .toString()
                                              .isNotEmpty)
                                        Text(
                                          "Feedback: ${sub['feedback']}",
                                          style:
                                              const TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),

                        /// 🔥 THIS IS THE ANSWER TO YOUR QUESTION
                        trailing: ElevatedButton(
                          child: Text(
                            type == 'recitation'
                                ? 'Answer'
                                : 'Submit',
                          ),
                          onPressed: () {
                            // ✅ RECITATION
                            if (type == 'recitation') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecitationScreen(
                                    assignmentId: a['id'],
                                  ),
                                ),
                              );
                              return;
                            }

                            // ✅ ACTIVITY (DEFAULT)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubmitAssignmentScreen(
                                  assignmentId: a['id'],
                                  title: a['title'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

/*import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';
import 'submit_assignment_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String classId;

  const StudentAssignmentsScreen({
    super.key,
    required this.classId,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen> {
  final AssignmentService _service = AssignmentService();
  bool loading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final res = await _service.getAssignments(widget.classId);
    setState(() {
      assignments = res;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? const Center(child: Text('No assignments yet'))
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final a = assignments[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6, 
                      child: ListTile(
                        title: Text(
                          a['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// 🔽 THIS IS WHERE YOUR FUTUREBUILDER GOES
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (a['description'] != null &&
                                a['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(a['description']),
                              ),

                            const SizedBox(height: 6),

                            /// ✅ ADDED — submission status
                            FutureBuilder<Map<String, dynamic>?>(
                              future: _service.getMySubmission(a['id']),
                              builder: (_, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Checking submission...",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                }

                                if (!snap.hasData || snap.data == null) {
                                  return const Text(
                                    "❌ Not submitted",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                final sub = snap.data!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "✅ Submitted",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (sub['grade'] != null)
                                      Text(
                                        "Grade: ${sub['grade']}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    if (sub['feedback'] != null &&
                                        sub['feedback']
                                            .toString()
                                            .isNotEmpty)
                                      Text(
                                        "Feedback: ${sub['feedback']}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),

                        /// ✅ SUBMIT BUTTON — UNTOUCHED
                        trailing: ElevatedButton(
                          child: const Text('Submit'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubmitAssignmentScreen(
                                  assignmentId: a['id'],
                                  title: a['title'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}*/

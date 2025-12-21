import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /* ===============================
     ASSIGNMENTS
     =============================== */

  Future<void> createAssignment({
    required String classId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final teacherId = _supabase.auth.currentUser!.id;

    await _supabase.from('assignments').insert({
      'class_id': classId,
      'teacher_id': teacherId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
        .from('assignments')
        .select('*')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await _supabase.from('assignments').delete().eq('id', assignmentId);
  }

  /* ===============================
     SUBMISSIONS
     =============================== */

  Future<String?> submitAssignment({
    required String assignmentId,
    required File file,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final assignment = await _supabase
          .from('assignments')
          .select('is_locked')
          .eq('id', assignmentId)
          .single();

      if (assignment['is_locked'] == true) {
        return "Submissions are closed";
      }

      final fileName = file.path.split('/').last;
      final path = '$userId/$assignmentId/$fileName';

      await _supabase.storage.from('assignment_uploads').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      await _supabase.from('assignment_submissions').upsert({
        'assignment_id': assignmentId,
        'student_id': userId,
        'file_url': path, // STORAGE PATH ONLY
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
    final submissions = await _supabase
        .from('assignment_submissions')
        .select('id, file_url, submitted_at, student_id')
        .eq('assignment_id', assignmentId)
        .order('submitted_at', ascending: false);

    final List<Map<String, dynamic>> result =
        List<Map<String, dynamic>>.from(submissions);

    for (int i = 0; i < result.length; i++) {
      final path = result[i]['file_url'];

      final signedUrl = await _supabase.storage
          .from('assignment_uploads')
          .createSignedUrl(path, 60 * 15);

      result[i]['file_path'] = path;        // ORIGINAL PATH
      result[i]['signed_url'] = signedUrl;  // VIEW URL

      final studentId = result[i]['student_id'];
      final profile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', studentId)
          .maybeSingle();

      result[i]['profile'] = profile;
    }

    return result;
  }

  Future<Map<String, dynamic>?> getMySubmission(String assignmentId) async {
    final userId = _supabase.auth.currentUser!.id;

    final res = await _supabase
        .from('assignment_submissions')
        .select('id, file_url, submitted_at, grade, feedback')
        .eq('assignment_id', assignmentId)
        .eq('student_id', userId)
        .maybeSingle();

    if (res == null) return null;

    final path = res['file_url'];

    final signedUrl = await _supabase.storage
        .from('assignment_uploads')
        .createSignedUrl(path, 60 * 15);

    res['file_path'] = path;
    res['signed_url'] = signedUrl;

    return res;
  }

  /* ===============================
     TEACHER CONTROLS
     =============================== */

  Future<void> updateAssignment({
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxPoints,
    bool? isLocked,
  }) async {
    await _supabase.from('assignments').update({
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      if (maxPoints != null) 'max_points': maxPoints,
      if (isLocked != null) 'is_locked': isLocked,
    }).eq('id', assignmentId);
  }

  Future<void> gradeSubmission({
    required String submissionId,
    required int grade,
    String? feedback,
  }) async {
    await _supabase.from('assignment_submissions').update({
      'grade': grade,
      'feedback': feedback,
    }).eq('id', submissionId);
  }
}

/*import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> startSession(String classId, String teacherId, int durationMinutes) async {
    try {
      final qrCode = Uuid().v4(); // unique QR code
      final startTime = DateTime.now().toUtc();
      final endTime = startTime.add(Duration(minutes: durationMinutes));

      await _supabase.from('attendance_sessions').insert({
        'class_id': classId,
        'teacher_id': teacherId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'qr_code': qrCode,
      });

      return qrCode;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSessions(String classId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final response = await _supabase
        .from('attendance_sessions')
        .select('*')
        .eq('class_id', classId)
        .gte('end_time', now); // only sessions not ended

    return List<Map<String, dynamic>>.from(response);
  }

  Future<String?> scanQR(String qrCode, String studentId) async {
    try {
      // Get session by QR code
      final session = await _supabase
          .from('attendance_sessions')
          .select('*')
          .eq('qr_code', qrCode)
          .maybeSingle();

      if (session == null) return "Invalid QR code";

      final now = DateTime.now().toUtc();
      final start = DateTime.parse(session['start_time']);
      final end = DateTime.parse(session['end_time']);

      String status;
      if (now.isBefore(start.add(Duration(minutes: 15)))) {
        status = "on_time";
      } else if (now.isBefore(start.add(Duration(minutes: 30)))) {
        status = "late";
      } else {
        status = "absent";
      }

      // Avoid duplicates
      final existing = await _supabase
          .from('attendance_records')
          .select('*')
          .eq('session_id', session['id'])
          .eq('student_id', studentId)
          .maybeSingle();

      if (existing != null) return "Already scanned";

      await _supabase.from('attendance_records').insert({
        'session_id': session['id'],
        'student_id': studentId,
        'status': status,
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getSessionAttendance(String sessionId) async {
    final response = await _supabase
        .from('attendance_records')
        .select('student_id, status, scanned_at, profiles(full_name)')
        .eq('session_id', sessionId);

    return List<Map<String, dynamic>>.from(response);
  }
  /// Fetch attendance history for a class
  Future<List<Map<String, dynamic>>> getAttendanceHistory(String classId) async {
    final sessions = await _supabase
        .from('attendance_sessions')
        .select('id, start_time')
        .eq('class_id', classId)
        .order('start_time', ascending: false);

    List<Map<String, dynamic>> history = [];

    for (var session in sessions) {
      final records = await _supabase
          .from('attendance_records')
          .select('student_id, status, scanned_at, profiles(full_name)')
          .eq('session_id', session['id']);

      history.add({
        'session_date': session['start_time'],
        'records': records,
      });
    }

    return history;
  }
}*/

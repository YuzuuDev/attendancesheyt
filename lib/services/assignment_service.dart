import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> submitAssignment({
    required String assignmentId,
    required String filePath,
  }) async {
    final user = _supabase.auth.currentUser!;
    final userId = user.id;

    final fileName = filePath.split('/').last;
    final storagePath = '$userId/$assignmentId/$fileName';

    // 1️⃣ Upload file
    await _supabase.storage
        .from('assignments')
        .upload(storagePath, File(filePath));

    // 2️⃣ Get public URL
    final fileUrl = _supabase.storage
        .from('assignments')
        .getPublicUrl(storagePath);

    // 3️⃣ Insert DB row (THIS is what the teacher reads)
    await _supabase.from('assignment_submissions').insert({
      'assignment_id': assignmentId,
      'student_id': userId,
      'file_url': fileUrl,
    });
  }
}

  /*Future<String?> submitAssignment({
    required String assignmentId,
    required String studentId,
    required File file,
  }) async {
    try {
      // 1️⃣ Check assignment due date
      final assignment = await _supabase
          .from('assignments')
          .select('due_date')
          .eq('id', assignmentId)
          .maybeSingle();
  
      if (assignment == null) return "Assignment not found";
  
      final due = assignment['due_date'];
      if (due != null &&
          DateTime.now().isAfter(DateTime.parse(due))) {
        return "Submission closed (past due date)";
      }
  
      // 2️⃣ Upload file
      final filePath =
          '$assignmentId/$studentId-${DateTime.now().millisecondsSinceEpoch}';
  
      await _supabase.storage
          .from('assignment_uploads')
          .upload(filePath, file);
  
      final fileUrl = _supabase.storage
          .from('assignment_uploads')
          .getPublicUrl(filePath);
  
      // 3️⃣ Insert submission
      await _supabase.from('assignment_submissions').insert({
        'assignment_id': assignmentId,
        'student_id': studentId,
        'file_url': fileUrl,
      });
  
      return null;
    } catch (e) {
      if (e.toString().contains('unique')) {
        return "You already submitted this assignment";
      }
      return e.toString();
    }
  }*/

  
  /// Teacher views submissions
  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
  final res = await _supabase
    .from('assignment_submissions')
    .select('*, profiles(full_name)')
    .eq('assignment_id', assignmentId);
    
    
    return List<Map<String, dynamic>>.from(res);
  }
  Future<void> gradeSubmission({
    required String submissionId,
    required int grade,
    required String feedback,
  }) async {
    await _supabase.from('assignment_submissions').update({
      'grade': grade,
      'feedback': feedback,
    }).eq('id', submissionId);
  }
  Future<void> deleteAssignment(String id) async {
    await _supabase
        .from('assignments')
        .delete()
        .eq('id', id);
  }

}

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /* =============================== ASSIGNMENTS =============================== */

  Future<void> createAssignment({
    required String classId,
    required String title,
    String? description,
    DateTime? dueDate,
    required String assignmentType,
    Uint8List? instructionBytes,
    String? instructionName,
  }) async {
    String? instructionPath;

    if (instructionBytes != null && instructionName != null) {
      instructionPath =
          'instructions/$classId/${DateTime.now().millisecondsSinceEpoch}_$instructionName';

      await _supabase.storage
          .from('assignment_instructions')
          .uploadBinary(
            instructionPath,
            instructionBytes,
            fileOptions: const FileOptions(upsert: true),
          );
    }

    await _supabase.from('assignments').insert({
      'class_id': classId,
      'teacher_id': _supabase.auth.currentUser!.id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'assignment_type': assignmentType,
      'instruction_file_url': instructionPath,
      'is_locked': false,
    });
  }

  /// ✅ TEACHER — UPDATE / REPLACE INSTRUCTION FILE
  Future<void> updateInstructionFile({
    required String assignmentId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final assignment = await _supabase
        .from('assignments')
        .select('class_id')
        .eq('id', assignmentId)
        .single();

    final path =
        'instructions/${assignment['class_id']}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage
        .from('assignment_instructions')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    await _supabase
        .from('assignments')
        .update({'instruction_file_url': path})
        .eq('id', assignmentId);
  }

  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
        .from('assignments')
        .select()
        .eq('class_id', classId)
        .order('created_at');

    final list = List<Map<String, dynamic>>.from(res);

    for (final a in list) {
      if (a['instruction_file_url'] != null) {
        a['instruction_signed_url'] =
            await _supabase.storage
                .from('assignment_instructions')
                .createSignedUrl(a['instruction_file_url'], 900);
      }
    }

    return list;
  }

  /* =============================== SUBMISSIONS =============================== */

  Future<String?> submitAssignment({
    required String assignmentId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final assignment = await _supabase
        .from('assignments')
        .select('is_locked, due_date')
        .eq('id', assignmentId)
        .single();

    if (assignment['is_locked'] == true) {
      return "Submissions are closed";
    }

    final path =
        'submissions/$assignmentId/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _supabase.storage
        .from('assignment_uploads')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    await _supabase.from('assignment_submissions').upsert({
      'assignment_id': assignmentId,
      'student_id': userId,
      'file_url': path,
    });

    return null;
  }

  /// ✅ EXACT SIGNATURE YOUR UI CALLS
  /// ✅ STUDENT — FULL UNSUBMIT (FILE + ROW)
  Future<void> unsubmit(String assignmentId, String studentId) async {
    final submission = await _supabase
        .from('assignment_submissions')
        .select('file_url')
        .eq('assignment_id', assignmentId)
        .eq('student_id', studentId)
        .maybeSingle();
  
    if (submission == null) return;
  
    final filePath = submission['file_url'];
  
    if (filePath != null) {
      await _supabase.storage
          .from('assignment_uploads')
          .remove([filePath]);
    }
  
    await _supabase
        .from('assignment_submissions')
        .delete()
        .eq('assignment_id', assignmentId)
        .eq('student_id', studentId);
  }


  Future<Map<String, dynamic>?> getMySubmission(String assignmentId) async {
    final userId = _supabase.auth.currentUser!.id;

    final res = await _supabase
        .from('assignment_submissions')
        .select('id, file_url, grade, feedback')
        .eq('assignment_id', assignmentId)
        .eq('student_id', userId)
        .maybeSingle();

    if (res == null) return null;

    res['signed_url'] = await _supabase.storage
        .from('assignment_uploads')
        .createSignedUrl(res['file_url'], 900);

    return res;
  }

  Future<List<Map<String, dynamic>>> getSubmissions(String assignmentId) async {
    final subs = await _supabase
        .from('assignment_submissions')
        .select('id, file_url, submitted_at, student_id')
        .eq('assignment_id', assignmentId);

    final list = List<Map<String, dynamic>>.from(subs);

    for (final s in list) {
      s['signed_url'] = await _supabase.storage
          .from('assignment_uploads')
          .createSignedUrl(s['file_url'], 900);
    }

    return list;
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

/*import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /* =============================== ASSIGNMENTS =============================== */

  Future<void> createAssignment({
    required String classId,
    required String title,
    String? description,
    DateTime? dueDate,
    required String assignmentType,
  }) async {
    await _supabase.from('assignments').insert({
      'class_id': classId,
      'teacher_id': _supabase.auth.currentUser!.id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'assignment_type': assignmentType,
    });
  }

  /*Future<void> createAssignment({
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
  }*/

  Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    return await _supabase
        .from('assignments')
        .select()
        .eq('class_id', classId)
        .order('created_at');
  }

  /*Future<List<Map<String, dynamic>>> getAssignments(String classId) async {
    final res = await _supabase
        .from('assignments')
        .select('*')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }*/

  Future<void> deleteAssignment(String assignmentId) async {
    await _supabase.from('assignments').delete().eq('id', assignmentId);
  }

  /* =============================== SUBMISSIONS =============================== */

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

      result[i]['file_path'] = path; // ORIGINAL PATH
      result[i]['signed_url'] = signedUrl; // VIEW URL

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

  /* =============================== TEACHER CONTROLS =============================== */

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
}*/

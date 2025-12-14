import 'package:supabase_flutter/supabase_flutter.dart';

class ClassService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CREATE CLASS
  Future<String?> createClass(String name, String teacherId) async {
    try {
      final code = _generateClassCode();
      await _supabase.from('classes').insert({
        'name': name,
        'code': code,
        'teacher_id': teacherId,
      });
      return code; // return the enrollment code to the teacher
    } catch (e) {
      return e.toString();
    }
  }

  // JOIN CLASS (STUDENT)
  Future<String?> joinClass(String code, String studentId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('id')
          .eq('code', code)
          .maybeSingle();

      if (response == null) return "Class not found";

      final classId = response['id'];

      await _supabase.from('class_students').insert({
        'class_id': classId,
        'student_id': studentId,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // GET STUDENTS IN A CLASS
  Future<List<Map<String, dynamic>>> getStudents(String classId) async {
    final response = await _supabase
        .from('class_students')
        .select('student_id, profiles(full_name, role)')
        .eq('class_id', classId);
    return response as List<Map<String, dynamic>>;
  }

  // Get all classes created by a teacher
  Future<List<Map<String, dynamic>>> getTeacherClasses(String teacherId) async {
    final response = await _supabase
        .from('classes')
        .select('id, name, code')
        .eq('teacher_id', teacherId);
    return response as List<Map<String, dynamic>>;
  }

  // Get all classes a student joined
  Future<List<Map<String, dynamic>>> getStudentClasses(String studentId) async {
    final response = await _supabase
        .from('class_students')
        .select('class_id, classes(name, code)')
        .eq('student_id', studentId);
    return response as List<Map<String, dynamic>>;
  }

  // HELPER: GENERATE 6-DIGIT CODE
  String _generateClassCode() {
    final random = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    return random.toString().padLeft(6, '0');
  }
}

import '../supabase_client.dart';

class RecitationService {
  final supabase = SupabaseClientInstance.supabase;

  // ======================
  // QUESTIONS
  // ======================

  Future<List<Map<String, dynamic>>> getQuestions(String assignmentId) async {
    final res = await supabase
        .from('recitation_questions')
        .select()
        .eq('assignment_id', assignmentId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> createQuestion({
    required String assignmentId,
    required String question,
    required String type, // mcq | text
    List<String>? choices,
    String? correctAnswer,
    int points = 1,
  }) async {
    await supabase.from('recitation_questions').insert({
      'assignment_id': assignmentId,
      'question_text': question,
      'type': type,
      'choices': choices,
      'correct_answer': correctAnswer,
      'points': points,
    });
  }

  // ======================
  // STUDENT ANSWERS
  // ======================

  Future<void> submitAnswer({
    required String questionId,
    required String answer,
  }) async {
    final user = supabase.auth.currentUser!;

    await supabase.from('recitation_answers').upsert({
      'question_id': questionId,
      'student_id': user.id,
      'answer': answer,
    });
  }

  // ======================
  // TEACHER VIEW
  // ======================

  Future<List<Map<String, dynamic>>> getAnswers(String questionId) async {
    final res = await supabase
        .from('recitation_answers')
        .select('answer, is_correct, points_awarded, profiles(full_name)')
        .eq('question_id', questionId);

    return List<Map<String, dynamic>>.from(res);
  }
}

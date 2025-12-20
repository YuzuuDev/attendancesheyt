import 'package:supabase_flutter/supabase_flutter.dart';

class ParticipationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Teacher gives points to student
  Future<String?> addPoints({
    required String studentId,
    required int points,
  }) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('participation_points')
          .eq('id', studentId)
          .maybeSingle();

      final current = profile?['participation_points'] ?? 0;

      await _supabase.from('profiles').update({
        'participation_points': current + points,
      }).eq('id', studentId);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Student views their points
  Future<int> getPoints(String studentId) async {
    final res = await _supabase
        .from('profiles')
        .select('participation_points')
        .eq('id', studentId)
        .maybeSingle();
  
    return res?['participation_points'] ?? 0;
  }

}

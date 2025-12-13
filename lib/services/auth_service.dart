import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // SIGN UP
  Future<String?> signUp(String email, String password, String fullName, String role) async {
    final response = await _supabase.auth.signUp(email: email, password: password);
    if (response.user != null) {
      // Add user to profiles table
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'role': role, // "teacher" or "student"
      });
      return null; // success
    }
    return response.error?.message;
  }

  // LOGIN
  Future<String?> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(email: email, password: password);
    return response.error?.message;
  }

  // RESET PASSWORD
  Future<String?> resetPassword(String email) async {
    final response = await _supabase.auth.resetPasswordForEmail(email);
    return response.error?.message;
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // SIGN UP
  Future<String?> signUp(String email, String password, String fullName, String role) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        // Add user to profiles table
        await _supabase.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'role': role, // "teacher" or "student"
        });
        return null; // success
      } else {
        return "Sign up failed";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user == null ? "Login failed" : null;
    } catch (e) {
      return e.toString();
    }
  }

  // RESET PASSWORD
  Future<String?> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

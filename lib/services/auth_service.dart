import '../supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = SupabaseClientInstance.supabase;

  // Sign Up
  Future<String?> signUp(String email, String password, String role) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Add role to profiles table
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'role': role,
        });
        return null; // success
      } else {
        return "Sign up failed";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      final SessionResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return null; // success
      } else {
        return "Login failed";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Password Reset
  Future<String?> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

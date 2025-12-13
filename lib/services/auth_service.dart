import '../supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = SupabaseClientInstance.supabase;

  // Sign Up
  Future<String?> signUp(String email, String password, String role) async {
    try {
      final response = await supabase.auth.signUp(
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
      }

      // If no user, sign up failed
      return "Sign up failed";
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return null; // success
      }

      return "Login failed";
    } catch (e) {
      return e.toString();
    }
  }

  // Reset Password
  Future<String?> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

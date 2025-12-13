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
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'role': role,
        });
        return null; // success
      } else if (response.error != null) {
        return response.error!.message;
      } else {
        return "Unknown signup error";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return null; // success
      } else if (response.error != null) {
        return response.error!.message;
      } else {
        return "Unknown login error";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Password Reset
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

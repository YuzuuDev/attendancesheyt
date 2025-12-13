import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Sign Up
  Future<String?> signUp(String email, String password, String role) async {
    final response = await supabase.auth.signUp(email: email, password: password);
    if (response.user != null) {
      // Add role to profiles table
      await supabase.from('profiles').insert({
        'id': response.user!.id,
        'role': role,
      });
      return null; // success
    } else {
      return response.error?.message ?? 'Unknown error';
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);
    return response.error?.message;
  }

  // Password Reset
  Future<String?> resetPassword(String email) async {
    final response = await supabase.auth.resetPasswordForEmail(email: email);
    return response.error?.message;
  }

  // Check if logged in
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

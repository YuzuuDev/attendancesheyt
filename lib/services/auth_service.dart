import '../supabase_client.dart';

class AuthService {
  final supabase = SupabaseClientInstance.supabase;

  // Sign Up
  Future<String?> signUp(String email, String password, String role) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await supabase.from('profiles').insert({
        'id': response.user!.id,
        'role': role,
      });
      return null;
    } else if (response.error != null) {
      return response.error!.message;
    } else {
      return 'Unknown error';
    }
  }

  // Sign In
  Future<String?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      return null;
    } else if (response.error != null) {
      return response.error!.message;
    } else {
      return 'Unknown error';
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

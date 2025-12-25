import 'package:supabase_flutter/supabase_flutter.dart';
import 'push_notification_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'role': role,
        });
        return null;
      } else {
        return "Sign up failed";
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
  
      if (response.user == null) {
        return "Login failed";
      }
  
      // 🔴 REQUIRED — REGISTER PUSH TOKEN AFTER LOGIN
      await PushNotificationService.registerDeviceToken();
      PushNotificationService.listenForegroundNotifications();
  
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /*Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user == null ? "Login failed" : null;
    } catch (e) {
      return e.toString();
    }
  }*/

  Future<String?> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

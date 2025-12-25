import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> registerDeviceToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('device_tokens').upsert({
      'user_id': user.id,
      'fcm_token': token,
      'platform': Platform.isAndroid ? 'android' : 'ios',
    });
  }
}

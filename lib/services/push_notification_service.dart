import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  static final _supabase = Supabase.instance.client;

  static Future<void> initAfterLogin() async {
    try {
      // 🔴 REQUEST PERMISSION SAFELY (NOT AT BOOT)
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _supabase.from('device_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });

      FirebaseMessaging.onMessage.listen((message) {
        // foreground debug
        print('🔔 PUSH: ${message.notification?.title}');
      });
    } catch (e) {
      // 🔴 PREVENTS NATIVE CRASHES
      print('🔥 Push init failed safely: $e');
    }
  }
}

/*import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  static final _supabase = Supabase.instance.client;

  static Future<void> registerDeviceToken() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await _supabase.from('device_tokens').upsert({
      'user_id': user.id,
      'fcm_token': token,
      'platform': Platform.isAndroid ? 'android' : 'ios',
    });
  }

  //new shit
  static void listenForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('🔔 PUSH RECEIVED');
        print('Title: ${message.notification!.title}');
        print('Body: ${message.notification!.body}');
      }
    });
  }

}*/

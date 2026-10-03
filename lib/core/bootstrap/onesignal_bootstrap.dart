import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OneSignalBootstrap {
  OneSignalBootstrap._();

  static const String appId = '17cd2a07-4e26-4f74-b202-2ff7c0e3d474';

  static Future<void> init() async {
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(appId);

      OneSignal.Notifications.requestPermission(true).then((granted) {
        debugPrint('OneSignal permission granted: $granted');
      });

      final localNoti = FlutterLocalNotificationsPlugin();

      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );
      await localNoti
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      const fgChannel = AndroidNotificationChannel(
        'wood_foreground_channel',
        'Wood App Service',
        description: 'ແອັບກຳລັງເຮັດວຽກຢູ່ເບື້ອງຫຼັງ',
        importance: Importance.low,
      );
      await localNoti
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(fgChannel);

      debugPrint('✅ Notification channels created');

      OneSignal.Notifications.addClickListener((event) {
        debugPrint('Notification clicked: ${event.notification.title}');
        Future.microtask(() {
          try {
            if (Get.currentRoute != '/notification') {
              Get.toNamed('/notification');
            }
          } catch (e) {
            debugPrint('Navigation error: $e');
          }
        });
      });

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.notification.display();
      });
    } catch (e, st) {
      debugPrint('OneSignal setup error: $e');
      debugPrint('$st');
    }
  }
}
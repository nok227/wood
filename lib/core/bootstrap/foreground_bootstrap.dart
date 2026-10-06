import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wood/firebase/foreground_task_handler.dart';

@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(WoodTaskHandler());
}

class ForegroundBootstrap {
  ForegroundBootstrap._();

  static Future<void> init() async {
    try {
      final hasPerm =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!hasPerm) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'wood_foreground_channel',
          channelName: 'Wood App Service',
          channelDescription: 'ແອັບກຳລັງເຮັດວຽກຢູ່ເບື້ອງຫຼັງ',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          autoRunOnBoot: true,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );

      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'ລາຄາໄມ້',
        notificationText: 'ກຳລັງເຮັດວຽກຢູ່ເບື້ອງຫຼັງ',
        callback: startForegroundCallback,
      );

      debugPrint('✅ Foreground service started: $result');
    } catch (e, st) {
      debugPrint('Foreground service error: $e');
      debugPrint('$st');
    }
  }
}
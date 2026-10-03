import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'core/util/page_route_notifier.dart';
import 'foreground_task_handler.dart';
import 'features/wood_products/data/datasources/notification_remote_data_source.dart';
import 'features/wood_products/data/datasources/sales_remote_data_source.dart';
import 'features/wood_products/data/repositories/notification_repository_impl.dart';
import 'features/wood_products/data/repositories/sales_repository_impl.dart';
import 'features/wood_products/presentation/controllers/notification_controller.dart';
import 'features/wood_products/presentation/controllers/sales_controller.dart';
import 'features/wood_products/presentation/controllers/wood_product_controller.dart';

import 'features/wood_products/data/datasources/account_remote_data_source.dart';
import 'features/wood_products/data/repositories/account_repository_impl.dart';
import 'features/wood_products/presentation/controllers/account_controller.dart';

import 'features/wood_products/data/datasources/recipe_remote_data_source.dart';
import 'features/wood_products/data/repositories/recipe_repository_impl.dart';
import 'features/wood_products/presentation/controllers/recipe_controller.dart';

import 'firebase_options.dart';
import 'features/wood_products/presentation/pages/home_shell.dart';
import 'features/auth/auth_remote_data_source.dart';
import 'features/auth/auth_repository_impl.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/register_page.dart';

// ✅ OneSignal App ID
const String oneSignalAppId = '17cd2a07-4e26-4f74-b202-2ff7c0e3d474';

// ✅ Callback สำหรับ Foreground Task — ต้องอยู่ top-level
@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(WoodTaskHandler());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════
  // 1. Firebase Initialization
  // ══════════════════════════════════════════
  Object? firebaseInitError;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e, st) {
    if (e.code == 'duplicate-app') {
      debugPrint('Firebase already initialized, skipping: ${e.code}');
    } else {
      debugPrint('Firebase init error: $e');
      debugPrint('$st');
      firebaseInitError = e;
    }
  } catch (e, st) {
    debugPrint('Firebase init error: $e');
    debugPrint('$st');
    firebaseInitError = e;
  }

  // ══════════════════════════════════════════
  // 2. OneSignal Initialization + Android Channel
  // ══════════════════════════════════════════
  if (firebaseInitError == null) {
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(oneSignalAppId);

      OneSignal.Notifications.requestPermission(true).then((granted) {
        debugPrint('OneSignal permission granted: $granted');
      });

      // ✅ สร้าง Android Notification Channel
      final FlutterLocalNotificationsPlugin localNotifications =
          FlutterLocalNotificationsPlugin();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      debugPrint('✅ Android notification channel created');

      // ✅ Foreground Service Channel (Importance LOW — ไม่เด้ง แต่ต้องมี)
      const AndroidNotificationChannel fgChannel = AndroidNotificationChannel(
        'wood_foreground_channel',
        'Wood App Service',
        description: 'ແອັບກຳລັງເຮັດວຽກຢູ່ເບື້ອງຫຼັງ',
        importance: Importance.low,
      );

      await localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(fgChannel);

      // ✅ ดักจับเมื่อกด notification
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
        debugPrint(
            'Foreground notification will display: ${event.notification.title}');
        event.notification.display();
      });
    } catch (e, st) {
      debugPrint('OneSignal setup error: $e');
      debugPrint('$st');
    }
  }

  // ══════════════════════════════════════════
  // 3. Foreground Service (ทำให้แอปทำงานหลังปัดออก)
  // ══════════════════════════════════════════
  if (firebaseInitError == null) {
    try {
      // ขอสิทธิ์ ignore battery optimization
      final hasPermission =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (!hasPermission) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // ตั้งค่า Foreground Task
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

      // เริ่ม service
      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'ລາຄາໄມ້',
        notificationText: 'ກຳລັງເຮັດວຽກຢູ່ເບື້ອງຫຼັງ',
        callback: startForegroundCallback,
      );

      debugPrint('✅ Foreground service started: $result');
    } catch (e, st) {
      debugPrint('Foreground service setup error: $e');
      debugPrint('$st');
    }
  }

  // ══════════════════════════════════════════
  // 4. Inject Controllers
  // ══════════════════════════════════════════
  Get.put(WoodProductController());

  final authRemoteDataSource = AuthRemoteDataSource();
  final authRepository =
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  Get.put(AuthController(authRepository: authRepository));

  final salesRemoteDataSource = SalesRemoteDataSource();
  final salesRepository =
      SalesRepositoryImpl(remoteDataSource: salesRemoteDataSource);
  Get.put(SalesController(repository: salesRepository));

  final accountRemoteDataSource = AccountRemoteDataSource();
  final accountRepository =
      AccountRepositoryImpl(remoteDataSource: accountRemoteDataSource);
  Get.put(AccountController(repository: accountRepository), permanent: true);

  final recipeRemote = RecipeRemoteDataSource();
  final recipeRepo = RecipeRepositoryImpl(remote: recipeRemote);
  Get.put(RecipeController(repository: recipeRepo), permanent: true);

  final notiRemote = NotificationRemoteDataSource();
  final notiRepo = NotificationRepositoryImpl(remote: notiRemote);
  Get.put(NotificationController(repository: notiRepo), permanent: true);

  runApp(MyApp(firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseInitError;
  const MyApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wood App',
      theme: ThemeData(primarySwatch: Colors.brown),
      routingCallback: (routing) {
        PageRouteNotifier.instance.bump();
      },
      home: firebaseInitError != null
          ? FirebaseErrorPage(error: firebaseInitError!)
          : (FirebaseAuth.instance.currentUser != null
              ? const HomeShell()
              : const RegisterPage()),
    );
  }
}

class FirebaseErrorPage extends StatelessWidget {
  final Object error;
  const FirebaseErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Firebase initialization failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(error.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}
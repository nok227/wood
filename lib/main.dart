import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wood/firebase_options.dart';
import 'package:wood/features/wood_products/presentation/pages/home_shell.dart';
import 'package:wood/features/wood_products/presentation/controllers/wood_product_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ครอบ try/catch ตอน Firebase init เพื่อไม่ให้แอปพังแบบเงียบ ๆ (จอขาว)
  // ถ้า Firebase init fail จริง จะเห็น error message บนหน้าจอแทนที่จะเจอจอขาวเปล่า
  Object? firebaseInitError;
  try {
    // ✅ เช็คก่อนว่ามี default app อยู่แล้วหรือยัง (เช่น ฝั่ง Android
    // auto-init ผ่าน google-services.json ไว้แล้ว) ถ้ามีแล้วก็ไม่ต้อง
    // initializeApp() ซ้ำ ป้องกัน [core/duplicate-app] error
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e, st) {
    if (e.code == 'duplicate-app') {
      // ไม่ใช่ error จริง — Firebase ใช้งานได้ปกติ แค่ถูก init ไปแล้วก่อนหน้า
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

  // ✅ สำคัญมาก: ต้อง put controller ก่อนที่หน้า UI จะเรียกใช้
  // นี่คือสาเหตุที่พบบ่อยที่สุดของอาการ "จอขาว" เมื่อใช้ GetX
  // (ถ้าไม่ put ไว้ก่อน แล้วหน้า page ไปเรียก Get.find<WoodProductController>()
  // มันจะ throw exception ทันทีตอน build widget แรก)
  Get.put(WoodProductController());

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
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      // ✅ ถ้า Firebase init fail จะโชว์หน้า error ที่เห็นได้ชัด
      // แทนที่จะปล่อยให้จอขาวเปล่าโดยไม่รู้สาเหตุ
      home: firebaseInitError != null
          ? FirebaseErrorPage(error: firebaseInitError!)
          : const HomeShell(),
    );
  }
}

/// หน้าจอแสดง error กรณี Firebase.initializeApp() ล้มเหลว
/// ช่วยให้เห็นสาเหตุจริงแทนที่จะเจอจอขาวเฉย ๆ
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
              const Text(
                'Firebase initialization failed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              const Text(
                'ตรวจสอบ:\n'
                '1. มีไฟล์ android/app/google-services.json หรือไม่\n'
                '2. applicationId ใน android/app/build.gradle ตรงกับ Firebase console หรือไม่\n'
                '3. android/build.gradle มี classpath google-services หรือไม่\n'
                '4. android/app/build.gradle มี apply plugin google-services หรือไม่',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
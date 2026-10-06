import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// ✅ Task Handler สำหรับ Foreground Service
@pragma('vm:entry-point')
class WoodTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('✅ Foreground service started at $timestamp');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // ทำงานซ้ำตาม interval — ตอนนี้ไม่ต้องทำอะไร
  }

  // ✅ แก้ไข: onDestroy รับเพียง DateTime เท่านั้น
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🛑 Foreground service destroyed at $timestamp');
  }

  // ✅ onReceiveData รับ Object (ตามที่แก้ไปก่อนหน้า)
  @override
  void onReceiveData(Object data) {
    debugPrint('📩 Received data: $data');
  }
}
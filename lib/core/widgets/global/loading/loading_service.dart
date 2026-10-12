// lib\core\widgets\global\loading\loading_service.dart
import 'package:flutter/material.dart';
import 'loading_dialog.dart';

/// 🎛️ Loading Service — เปิด/ปิด dialog จากทุกที่ (วางทับทั้งจอ)
class LoadingService {
  LoadingService._();

  static bool _isShowing = false;

  static bool get isShowing => _isShowing;

  /// เปิด dialog วางทับ
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.25),
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: LoadingDialog(message: message),
      ),
    ).then((_) => _isShowing = false);
  }

  /// ปิด dialog
  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// ครอบงาน async ให้เปิด-ปิดอัตโนมัติ
  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() task, {
    String? message,
  }) async {
    show(context, message: message);
    try {
      return await task();
    } finally {
      if (context.mounted) hide(context);
    }
  }
}
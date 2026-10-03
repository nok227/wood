import 'package:flutter/foundation.dart';

class NetworkInfo {
  static Future<bool> get isConnected async {
    try {
      // TODO: ต่อกับ connectivity_plus ในอนาคต
      return true;
    } catch (e) {
      debugPrint('NetworkInfo error: $e');
      return false;
    }
  }
}
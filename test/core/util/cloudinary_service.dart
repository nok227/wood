import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // ═══════════════════════════════════════════════
  // 📌 ຄ່າຈາກ Cloudinary Dashboard
  // ═══════════════════════════════════════════════
  static const String cloudName = 'onvap9ey';
  static const String uploadPreset = 'wood_preset';

  // 🔑 ສຳລັບ "ລຶບ" — ດຶງຈາກ Dashboard → Settings → Access Keys
  static const String _apiKey = '532548648378927';       // ⬅️ ໃສ່ຄ່າຈິງ
  static const String _apiSecret = 'yRGJ66uDA540X0UIGQSkTSeGXJ8'; // ⬅️ ໃສ່ຄ່າຈິງ

  // ═══════════════════════════════════════════════
  // ⬆️ ອັບໂຫຼດຮູບ (unsigned — ຄືເກົ່າ)
  // ═══════════════════════════════════════════════
  static Future<String?> uploadImage(
    File imageFile, {
    String folder = 'sales',
  }) async {
    if (cloudName.startsWith('YOUR_') || uploadPreset.startsWith('YOUR_')) {
      debugPrint(
          'Cloudinary: ຍັງບໍ່ໄດ້ຕັ້ງ cloudName / uploadPreset');
      throw Exception(
          'ຍັງບໍ່ໄດ້ຕັ້ງຄ່າ Cloudinary (cloudName / uploadPreset)');
    }

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      debugPrint('Cloudinary ${streamed.statusCode}: $body');
      String msg = body;
      try {
        msg = jsonDecode(body)['error']['message'].toString();
      } catch (_) {}
      throw Exception('Cloudinary ${streamed.statusCode}: $msg');
    }

    final jsonMap = jsonDecode(body);
    final String rawUrl = jsonMap['secure_url'];
    return _optimizeCloudinaryUrl(rawUrl);
  }

  static String _optimizeCloudinaryUrl(String rawUrl) {
    return rawUrl.replaceFirst(
      '/upload/',
      '/upload/f_auto,q_auto,c_limit,w_2000,h_2000/',
    );
  }

  // ═══════════════════════════════════════════════
  // 🗑️ ລຶບຮູບ (signed — ຕ້ອງມີ api_key + api_secret)
  // ═══════════════════════════════════════════════

  /// ດຶງ public_id ຈາກ URL Cloudinary
  /// ຕົວຢ່າງ:
  /// https://res.cloudinary.com/onvap9ey/image/upload/f_auto,q_auto,c_limit,w_2000,h_2000/v123/sales/sale1.jpg
  /// → "sales/sale1"
  static String? _extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.host.contains('cloudinary.com')) return null;

      final seg = uri.pathSegments;
      final idx = seg.indexOf('upload');
      if (idx == -1 || idx + 1 >= seg.length) return null;

      int start = idx + 1;
      // ຂ້າມ transform params ທັງໝົດ (f_auto, q_auto, ...)
      while (start < seg.length &&
          !(seg[start].startsWith('v') &&
              int.tryParse(seg[start].substring(1)) != null)) {
        // ຖ້າບໍ່ແມ່ນ version ແລະ ຍັງບໍ່ຮອດທ້າຍ → ຂ້າມ
        if (seg[start].contains(',')) {
          start++;
        } else {
          break;
        }
      }
      // ຂ້າມ version ຖ້າມີ
      if (start < seg.length &&
          seg[start].startsWith('v') &&
          int.tryParse(seg[start].substring(1)) != null) {
        start++;
      }

      final idWithExt = seg.sublist(start).join('/');
      final dot = idWithExt.lastIndexOf('.');
      return dot > 0 ? idWithExt.substring(0, dot) : idWithExt;
    } catch (_) {
      return null;
    }
  }

  /// ລຶບຮູບ 1 ຮູບ
  static Future<bool> deleteImage(String url) async {
    if (_apiKey.startsWith('YOUR_') || _apiSecret.startsWith('YOUR_')) {
      debugPrint('Cloudinary: ຍັງບໍ່ໄດ້ຕັ້ງ api_key / api_secret');
      return false;
    }

    final pid = _extractPublicId(url);
    if (pid == null) {
      debugPrint('Cloudinary: ບໍ່ສາມາດດຶງ public_id ຈາກ $url');
      return false;
    }

    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // signature = SHA1(public_id=xxx&timestamp=yyy + api_secret)
    final signature = sha1
        .convert(utf8.encode('public_id=$pid&timestamp=$ts$_apiSecret'))
        .toString();

    try {
      final resp = await http.post(
        Uri.parse(
            'https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
        body: {
          'public_id': pid,
          'api_key': _apiKey,
          'timestamp': '$ts',
          'signature': signature,
        },
      );

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final result = json['result'];
        debugPrint('Cloudinary delete $pid → $result');
        return result == 'ok' || result == 'not found';
      }

      debugPrint('Cloudinary delete failed ${resp.statusCode}: ${resp.body}');
      return false;
    } catch (e) {
      debugPrint('Cloudinary delete error: $e');
      return false;
    }
  }

  /// ລຶບຫຼາຍຮູບພ້ອມກັນ
  static Future<void> deleteImages(List<String> urls) async {
    final valid = urls.where((u) => u.isNotEmpty).toList();
    if (valid.isEmpty) return;
    await Future.wait(valid.map(deleteImage));
  }
}
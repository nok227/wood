import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'onvap9ey';
  static const String uploadPreset = 'wood_preset';

  static const String _apiKey = '532548648378927';
  static const String _apiSecret = 'yRGJ66uDA540X0UIGQSkTSeGXJ8';

  // ═══════════════════════════════════════════════
  // ⬆️ ອັບໂຫຼດຮູບ
  // ═══════════════════════════════════════════════
  static Future<String?> uploadImage(
    File imageFile, {
    String folder = 'sales',
  }) async {
    if (cloudName.startsWith('YOUR_') || uploadPreset.startsWith('YOUR_')) {
      debugPrint('Cloudinary: ຍັງບໍ່ໄດ້ຕັ້ງ cloudName / uploadPreset');
      throw Exception('ຍັງບໍ່ໄດ້ຕັ້ງຄ່າ Cloudinary');
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
  // 🗑️ ລຶບຮູບ
  // ═══════════════════════════════════════════════
  static String? _extractPublicId(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.host.contains('cloudinary.com')) return null;

      final seg = uri.pathSegments;
      final idx = seg.indexOf('upload');
      if (idx == -1 || idx + 1 >= seg.length) return null;

      int start = idx + 1;
      while (start < seg.length &&
          !(seg[start].startsWith('v') &&
              int.tryParse(seg[start].substring(1)) != null)) {
        if (seg[start].contains(',')) {
          start++;
        } else {
          break;
        }
      }
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
    final signature = sha1
        .convert(utf8.encode('public_id=$pid&timestamp=$ts$_apiSecret'))
        .toString();

    try {
      final resp = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
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

  static Future<void> deleteImages(List<String> urls) async {
    final valid = urls.where((u) => u.isNotEmpty).toList();
    if (valid.isEmpty) return;
    await Future.wait(valid.map(deleteImage));
  }
}
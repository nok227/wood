import 'dart:async';

import 'package:get/get.dart';

import 'package:wood/core/widgets/global/app_snackbar.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AdminUsersController extends GetxController {
  final AuthRepository authRepository;
  AdminUsersController({required this.authRepository});

  // ── State ──
  final usersList = <AppUser>[].obs;
  final usersLoading = false.obs;

  StreamSubscription<List<AppUser>>? _sub;

  // ══════════════════════════════════════════
  // ⭐ เริ่ม listen (เรียกครั้งแรกตอนเปิดหน้า)
  // ══════════════════════════════════════════
  void startListening() {
    if (_sub != null) return; // กัน duplicate
    _subscribe();
  }

  // ══════════════════════════════════════════
  // ⭐ ปุ่ม refresh → ยกเลิก stream เก่า + เริ่มใหม่
  // ══════════════════════════════════════════
  Future<void> refreshUsers() async {
    await _sub?.cancel();
    _sub = null;
    _subscribe();
    AppSnackbar.ok('ສຳເລັດ', 'ອັບເດດຂໍ້ມູນແລ້ວ');
  }

  // ══════════════════════════════════════════
  // Internal — subscribe stream
  // ══════════════════════════════════════════
  void _subscribe() {
    usersLoading.value = true;
    _sub = authRepository.usersStream().listen(
      (list) {
        usersList.assignAll(list);
        usersLoading.value = false;
      },
      onError: (_) {
        AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດໂຫຼດຜູ້ໃຊ້ໄດ້');
        usersLoading.value = false;
      },
    );
  }

  // ══════════════════════════════════════════
  // อัปเดตสิทธิ์ (คงเดิม)
  // ══════════════════════════════════════════
  Future<bool> updateUserMenuPermissions(
    String uid,
    List<String> menus,
  ) async {
    try {
      await authRepository.updateAllowedMenus(uid, menus);
      return true;
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກສິດໄດ້: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
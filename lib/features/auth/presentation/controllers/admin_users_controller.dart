import 'package:get/get.dart';

import 'package:wood/core/widgets/global/app_snackbar.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AdminUsersController extends GetxController {
  final AuthRepository authRepository;
  AdminUsersController({required this.authRepository});

  final usersList = <AppUser>[].obs;
  final usersLoading = false.obs;

  Future<void> loadUsers() async {
    usersLoading.value = true;
    try {
      final list = await authRepository.getUsers();
      usersList.assignAll(list);
    } catch (_) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດໂຫຼດຜູ້ໃຊ້ໄດ້');
    } finally {
      usersLoading.value = false;
    }
  }

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
}
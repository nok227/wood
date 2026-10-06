import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/home/presentation/pages/home_shell.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/menu_permission.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // ── Form controllers ──
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ── State ──
  var isLoading = false.obs;
  var currentUser = Rxn<AppUser>();
  var permissionLoaded = false.obs;

  // ── Admin: users list ──
  var usersList = <AppUser>[].obs;
  var usersLoading = false.obs;

  StreamSubscription? _authSub;
  StreamSubscription? _userDocSub;
  String? _lastBoundUid;

  // ══════════════════════════════════════════
  // Getters
  // ══════════════════════════════════════════
  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  bool get hasAnyPermission {
    if (isAdmin) return true;
    return (currentUser.value?.allowedMenus.isNotEmpty) ?? false;
  }

  bool canAccess(MenuKey k) {
    if (isAdmin) return true;
    final menus = currentUser.value?.allowedMenus ?? const [];
    return menus.contains(k.key);
  }

  // ══════════════════════════════════════════
  // Init
  // ══════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _authSub = authRepository.authStateStream().listen(_onAuthChanged);
  }

  void _onAuthChanged(AppUser? user) {
    currentUser.value = user;
    _bindUserDoc(user?.uid);

    if (user != null) {
      _linkOneSignalUser(user.uid);
    }
  }

  void _bindUserDoc(String? uid) {
    if (_lastBoundUid == uid && _userDocSub != null) return;
    _lastBoundUid = uid;

    _userDocSub?.cancel();
    _userDocSub = null;

    if (uid == null) {
      permissionLoaded.value = false;
      return;
    }

    permissionLoaded.value = false;

    _userDocSub = authRepository.userStream(uid).listen(
      (u) {
        if (u != null) {
          currentUser.value = u;
        }
        permissionLoaded.value = true;
      },
      onError: (_) {
        permissionLoaded.value = true;
      },
    );
  }

  // ══════════════════════════════════════════
  // Form
  // ══════════════════════════════════════════
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  // ══════════════════════════════════════════
  // OneSignal
  // ══════════════════════════════════════════
  void _linkOneSignalUser(String uid) {
    try {
      OneSignal.login(uid);
    } catch (_) {}
  }

  // ══════════════════════════════════════════
  // 🔐 Register
  // ══════════════════════════════════════════
  Future<void> registerWithEmail() async {
    try {
      isLoading.value = true;
      await authRepository.registerWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      clearForm();
      Get.offAll(() => const HomeShell());
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════
  // 🔑 Login
  // ══════════════════════════════════════════
  Future<void> signInWithEmail() async {
    try {
      isLoading.value = true;
      await authRepository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      clearForm();
      Get.offAll(() => const HomeShell());
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        clearForm();
        Get.offAll(() => const HomeShell());
      }
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════
  // 🚪 Logout
  // ══════════════════════════════════════════
  Future<void> logout() async {
    try {
      OneSignal.logout();
    } catch (_) {}
    await authRepository.signOut();
    clearForm();
  }

  // ══════════════════════════════════════════
  // 👥 Admin — users list
  // ══════════════════════════════════════════
  Future<void> loadUsers() async {
    if (!isAdmin) return;

    usersLoading.value = true;
    try {
      final list = await authRepository.getUsers();
      usersList.assignAll(list);
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດໂຫຼດຜູ້ໃຊ້ໄດ້');
    } finally {
      usersLoading.value = false;
    }
  }

  // ══════════════════════════════════════════
  // 👤 Admin — update permissions
  // ══════════════════════════════════════════
  Future<bool> updateUserMenuPermissions(
    String uid,
    List<String> menus,
  ) async {
    if (!isAdmin) return false;
    try {
      await authRepository.updateAllowedMenus(uid, menus);
      return true;
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', 'ບໍ່ສາມາດບັນທຶກສິດໄດ້: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════
  // Dispose
  // ══════════════════════════════════════════
  @override
  void onClose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
import 'dart:async';

import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:wood/core/widgets/global/app_snackbar.dart';
import 'package:wood/features/home/presentation/pages/home_shell.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/menu_permission.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_controller.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  AuthController({required this.authRepository});

  // ── State ──
  var isLoading = false.obs;
  var currentUser = Rxn<AppUser>();
  var permissionLoaded = false.obs;

  StreamSubscription? _authSub;
  StreamSubscription? _userDocSub;
  String? _lastBoundUid;

  // ── Getters ──
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

  // ── Init ──
  @override
  void onInit() {
    super.onInit();
    _authSub = authRepository.authStateStream().listen(_onAuthChanged);
  }

  void _onAuthChanged(AppUser? user) {
    currentUser.value = user;
    _bindUserDoc(user?.uid);

    if (user != null) _linkOneSignalUser(user.uid);
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
        if (u != null) currentUser.value = u;
        permissionLoaded.value = true;
      },
      onError: (_) => permissionLoaded.value = true,
    );
  }

  void _linkOneSignalUser(String uid) {
    try {
      OneSignal.login(uid);
    } catch (_) {}
  }

  // ── Register ──
  Future<void> registerWithEmail() async {
    final form = Get.find<AuthFormController>();
    try {
      isLoading.value = true;
      await authRepository.registerWithEmail(
        name: form.nameController.text.trim(),
        email: form.emailController.text.trim(),
        password: form.passwordController.text.trim(),
      );
      form.clear();
      Get.offAll(() => const HomeShell());
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login ──
  Future<void> signInWithEmail() async {
    final form = Get.find<AuthFormController>();
    try {
      isLoading.value = true;
      await authRepository.signInWithEmail(
        email: form.emailController.text.trim(),
        password: form.passwordController.text.trim(),
      );
      form.clear();
      Get.offAll(() => const HomeShell());
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    final form = Get.find<AuthFormController>();
    try {
      isLoading.value = true;
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        form.clear();
        Get.offAll(() => const HomeShell());
      }
    } catch (e) {
      AppSnackbar.err('ຜິດພາດ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ──
  Future<void> logout() async {
    try {
      OneSignal.logout();
    } catch (_) {}
    await authRepository.signOut();
    Get.find<AuthFormController>().clear();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.onClose();
  }
}
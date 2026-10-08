import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';

import '../../domain/entities/menu_permission.dart';
import '../controllers/admin_users_controller.dart';
import '../widgets/permission/permission_header.dart';
import '../widgets/permission/permission_info_box.dart';
import '../widgets/permission/permission_menu_tile.dart';
import '../widgets/permission/permission_presets.dart';
import '../widgets/permission/permission_save_button.dart';

class UserPermissionPage extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final List<String> initialAllowed;

  const UserPermissionPage({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.initialAllowed,
  });

  @override
  State<UserPermissionPage> createState() => _UserPermissionPageState();
}

class _UserPermissionPageState extends State<UserPermissionPage> {
  final admin = Get.find<AdminUsersController>();
  late Set<MenuKey> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialAllowed
        .map(MenuKey.fromKey)
        .whereType<MenuKey>()
        .toSet();
  }

  void _toggle(MenuKey k) {
    setState(() {
      if (_selected.contains(k)) {
        _selected.remove(k);
      } else {
        _selected.add(k);
      }
    });
  }

  void _presetViewOnly() {
    setState(() {
      _selected = {
        MenuKey.woodList,
        MenuKey.salesList,
        MenuKey.account,
        MenuKey.wood3d,
      };
    });
  }

  void _presetAll() {
    setState(() => _selected = MenuKey.values.toSet());
  }

  void _presetNone() {
    setState(() => _selected = {});
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final menus = _selected.map((e) => e.key).toList()..sort();
      final ok = await admin.updateUserMenuPermissions(widget.uid, menus);
      if (ok && mounted) {
        Get.back();
        AppSnackbar.ok(
          AuthStyle.successMsg,
          '${AuthStyle.permissionSaveSuccess} ${widget.name} ${AuthStyle.permissionSaveSuccessSuffix}',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthStyle.bg,
      appBar: AppBar(
        title: const Text(AuthStyle.permissionTitle),
        backgroundColor: AuthStyle.primary,
        foregroundColor: AuthStyle.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: AuthStyle.padPageList,
            children: [
              PermissionHeader(
                name: widget.name,
                email: widget.email,
              ),
              AuthStyle.gapLg,
              PermissionPresets(
                onViewOnly: _presetViewOnly,
                onAll: _presetAll,
                onNone: _presetNone,
              ),
              AuthStyle.gapLg,
              const PermissionInfoBox(),
              AuthStyle.gapLg,
              Text(
                AuthStyle.menuAllowed,
                style: AuthStyle.sectionLabel.copyWith(color: AuthStyle.primary),
              ),
              AuthStyle.gapSm,
              ...MenuKey.values.map(
                (k) => PermissionMenuTile(
                  menuKey: k,
                  isSelected: _selected.contains(k),
                  onToggle: () => _toggle(k),
                ),
              ),
              AuthStyle.gap24W,
              PermissionSaveButton(
                isSaving: _saving,
                onSave: _save,
              ),
            ],
          ),
          if (_saving)
            Positioned.fill(
              child: Container(
                color: AuthStyle.black12,
                child: const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
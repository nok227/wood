import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wood/core/constants/specific/auth_style.dart';
import 'package:wood/core/widgets/global/app_snackbar.dart';
import '../controllers/auth_controller.dart';
import '../../domain/entities/menu_permission.dart';

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
  final auth = Get.find<AuthController>();
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
      final ok = await auth.updateUserMenuPermissions(widget.uid, menus);
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
              _header(),
              AuthStyle.gapLg,
              _presets(),
              AuthStyle.gapLg,
              Container(
                padding: AuthStyle.padInfo,
                decoration: BoxDecoration(
                  color: AuthStyle.amber50,
                  borderRadius: AuthStyle.r10,
                  border: Border.all(color: AuthStyle.amber300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: AuthStyle.iconPreset,
                      color: AuthStyle.amber900,
                    ),
                    AuthStyle.gapSm,
                    const Expanded(
                      child: Text(
                        AuthStyle.permissionInfo,
                        style: AuthStyle.infoText,
                      ),
                    ),
                  ],
                ),
              ),
              AuthStyle.gapLg,
              Text(
                AuthStyle.menuAllowed,
                style: AuthStyle.sectionLabel.copyWith(
                  color: AuthStyle.primary,
                ),
              ),
              AuthStyle.gapSm,
              ...MenuKey.values.map(_menuTile),
              AuthStyle.gap24W,
              SizedBox(
                height: AuthStyle.buttonHeight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuthStyle.primary,
                    foregroundColor: AuthStyle.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AuthStyle.r12,
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: AuthStyle.spinnerSmall,
                          height: AuthStyle.spinnerSmall,
                          child: CircularProgressIndicator(
                            strokeWidth: AuthStyle.spinnerStroke,
                            color: AuthStyle.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _saving ? AuthStyle.saving : AuthStyle.save,
                    style: AuthStyle.saveBtnText,
                  ),
                ),
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

  Widget _header() {
    return Container(
      padding: AuthStyle.padHeader,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AuthStyle.brown700, AuthStyle.brown500],
        ),
        borderRadius: AuthStyle.r14,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: AuthStyle.avatarMd,
            backgroundColor: AuthStyle.white24,
            child: Icon(
              Icons.person,
              color: AuthStyle.white,
              size: AuthStyle.iconAvatarMd,
            ),
          ),
          AuthStyle.gap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: AuthStyle.profileNameSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AuthStyle.gap2,
                Text(
                  widget.email,
                  style: AuthStyle.profileEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presets() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _presetViewOnly,
            icon: const Icon(
              Icons.visibility_outlined,
              size: AuthStyle.iconPreset,
            ),
            label: const Text(AuthStyle.viewOnly),
            style: OutlinedButton.styleFrom(
              foregroundColor: AuthStyle.primary,
              side: const BorderSide(color: AuthStyle.brown300),
              padding: AuthStyle.padPresetBtn,
            ),
          ),
        ),
        AuthStyle.gapSm,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _presetAll,
            icon: const Icon(Icons.done_all, size: AuthStyle.iconPreset),
            label: const Text(AuthStyle.allMenus),
            style: OutlinedButton.styleFrom(
              foregroundColor: AuthStyle.successDark,
              side: const BorderSide(color: AuthStyle.success300),
              padding: AuthStyle.padPresetBtn,
            ),
          ),
        ),
        AuthStyle.gapSm,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _presetNone,
            icon: const Icon(Icons.block, size: AuthStyle.iconPreset),
            label: const Text(AuthStyle.noAccess),
            style: OutlinedButton.styleFrom(
              foregroundColor: AuthStyle.error700,
              side: const BorderSide(color: AuthStyle.error300),
              padding: AuthStyle.padPresetBtn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(MenuKey k) {
    final on = _selected.contains(k);
    return Container(
      margin: AuthStyle.marginTileBottom,
      decoration: BoxDecoration(
        color: AuthStyle.white,
        borderRadius: AuthStyle.cardRadius,
        border: Border.all(
          color: on ? AuthStyle.brown400 : AuthStyle.grey300,
          width: on
              ? AuthStyle.borderWidthSelected
              : AuthStyle.borderWidthNormal,
        ),
        boxShadow: AuthStyle.cardLocal,
      ),
      child: CheckboxListTile(
        value: on,
        onChanged: (_) => _toggle(k),
        activeColor: AuthStyle.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: AuthStyle.cardRadius,
        ),
        title: Row(
          children: [
            Icon(
              k.icon,
              size: AuthStyle.iconMenuTile,
              color: AuthStyle.primary,
            ),
            AuthStyle.gapSm,
            Text(k.label, style: AuthStyle.menuTileTitle),
          ],
        ),
        subtitle: Text(
          '${AuthStyle.keyPrefix}${k.key}',
          style: AuthStyle.menuTileKey,
        ),
      ),
    );
  }
}
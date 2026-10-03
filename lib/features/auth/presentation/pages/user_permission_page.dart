import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        Get.snackbar(
          'ສຳເລັດ',
          'ອັບເດດສິດຂອງ ${widget.name} ແລ້ວ',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('ກຳນົດສິດການເຂົ້າເຖິງ'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(),
              const SizedBox(height: 16),
              _presets(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ຖ້າບໍ່ເລືອກເມນູໃດເລີຍ ຜູ້ໃຊ້ຈະເຫັນໜ້າ "ຢູ່ລະຫວ່າງການກວດສອບ"',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ເມນູທີ່ອະນຸຍາດ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),
              ...MenuKey.values.map(_menuTile),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _saving ? 'ກຳລັງບັນທຶກ...' : 'ບັນທຶກ',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_saving)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade700, Colors.brown.shade500],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('ເບິ່ງຢ່າງດຽວ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.brown,
              side: BorderSide(color: Colors.brown.shade300),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _presetAll,
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('ທັງໝົດ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade800,
              side: BorderSide(color: Colors.green.shade300),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _presetNone,
            icon: const Icon(Icons.block, size: 16),
            label: const Text('ບໍ່ໃຫ້'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuTile(MenuKey k) {
    final on = _selected.contains(k);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: on ? Colors.brown.shade400 : Colors.grey.shade300,
          width: on ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: on,
        onChanged: (_) => _toggle(k),
        activeColor: Colors.brown.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(k.icon, size: 18, color: Colors.brown.shade700),
            const SizedBox(width: 8),
            Text(
              k.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          'key: ${k.key}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
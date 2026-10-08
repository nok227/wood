import 'package:flutter/material.dart';
import 'package:wood/core/constants/specific/auth_style.dart';

class PermissionSaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const PermissionSaveButton({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthStyle.buttonHeight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthStyle.primary,
          foregroundColor: AuthStyle.white,
          shape: const RoundedRectangleBorder(
            borderRadius: AuthStyle.r12,
          ),
        ),
        onPressed: isSaving ? null : onSave,
        icon: isSaving
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
          isSaving ? AuthStyle.saving : AuthStyle.save,
          style: AuthStyle.saveBtnText,
        ),
      ),
    );
  }
}
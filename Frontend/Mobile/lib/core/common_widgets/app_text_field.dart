import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String initialValue;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool requiredField;
  final AutovalidateMode autovalidateMode;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.obscureText = true,
    this.onToggleObscure,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.initialValue = '',
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.requiredField = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.errorText,
  }) : assert(
         controller == null || initialValue == '',
         'Provide either controller or initialValue, not both.',
       );

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: isPassword && obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label.isNotEmpty ? label : null,
            floatingLabelBehavior: label.isNotEmpty 
                ? FloatingLabelBehavior.auto 
                : FloatingLabelBehavior.never,
            hintText: hint,
            errorText: errorText,
            errorStyle: TextStyle(
              color: palette.danger,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: palette.textSecondary, size: 20)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: palette.textSecondary,
                      size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: enabled ? palette.surface : palette.surfaceMuted,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: palette.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.danger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: palette.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

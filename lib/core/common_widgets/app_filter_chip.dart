import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? palette.surface : palette.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      avatar: selected
          ? Icon(Icons.check_circle, size: 16, color: palette.surface)
          : null,
      selectedColor: palette.primary,
      backgroundColor: palette.surface,
      side: BorderSide(
        color: selected ? palette.primary : palette.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

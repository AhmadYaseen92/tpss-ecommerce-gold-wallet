import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';

class WalletTabBar extends StatelessWidget {
  const WalletTabBar({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Row(
        children: ProductCategoryFilter.options.map((category) {
          final isSelected = category.categoryId == selectedCategoryId;

          return Expanded(
            child: GestureDetector(
              onTap: () => onCategoryTap(category.categoryId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: isSelected ? palette.primary.withAlpha(25) : AppColors.transparent,
                  borderRadius: BorderRadius.circular(50.0),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4.0, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? palette.primary : palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

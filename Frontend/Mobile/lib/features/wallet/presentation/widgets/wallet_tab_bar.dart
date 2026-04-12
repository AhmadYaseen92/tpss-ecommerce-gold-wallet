import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ProductCategoryFilter.options.map((category) {
          final isSelected = category.categoryId == selectedCategoryId;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppFilterChip(
              label: category.label,
              selected: isSelected,
              onTap: () => onCategoryTap(category.categoryId),
            ),
          );
        }).toList(),
      ),
    );
  }
}

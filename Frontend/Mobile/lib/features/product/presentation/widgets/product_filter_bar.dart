import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';

class ProductFilterBar extends StatelessWidget {
  final ProductCubit productCubit;
  const ProductFilterBar({super.key, required this.productCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      bloc: productCubit,
      builder: (context, state) {
        var selectedCategoryId = productCubit.selectedCategoryId;
        if (state is ProductLoaded) {
          selectedCategoryId = state.categoryId;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ProductCategoryFilter.options.map((category) {
                final isSelected = selectedCategoryId == category.categoryId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AppFilterChip(
                    label: category.label,
                    selected: isSelected,
                    onTap: () => productCubit.applyCategoryFilter(categoryId: category.categoryId),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

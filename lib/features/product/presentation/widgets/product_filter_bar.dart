import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/product/presentation/cubit/product_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/app_filter_chip.dart';

class ProductFilterBar extends StatelessWidget {
  final ProductCubit productCubit;
  const ProductFilterBar({super.key, required this.productCubit});

  static const List<String> categories = ['All', 'Bullion', 'Jewellery', 'Coins'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      bloc: productCubit,
      builder: (context, state) {
        var selectedCategory = productCubit.selectedCategory;
        if (state is ProductLoaded) {
          selectedCategory = state.category;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AppFilterChip(
                    label: category,
                    selected: isSelected,
                    onTap: () => productCubit.applyCategoryFilter(category: category),
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

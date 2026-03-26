import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';

class ProductFilterBar extends StatelessWidget {
  final ProductCubit productCubit;
  const ProductFilterBar({super.key, required this.productCubit});

  static const List<String> categories = ['All', 'Bullion', 'Jewellery', 'Coins'];
  static const List<String> sellers = ['All Sellers', 'Imseeh', 'Sakkejha', 'Da’naa'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      bloc: productCubit,
      builder: (context, state) {
        var selectedCategory = productCubit.selectedCategory;
        var selectedSeller = productCubit.selectedSeller;
        if (state is ProductLoaded) {
          selectedCategory = state.category;
          selectedSeller = state.seller;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => productCubit.applyFilters(category: category),
                        selectedColor: AppColors.luxuryIvory,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: sellers.map((seller) {
                    final isSelected = selectedSeller == seller;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(seller),
                        selected: isSelected,
                        onSelected: (_) => productCubit.applyFilters(seller: seller),
                        selectedColor: AppColors.white,
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryColor : AppColors.greyBorder,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryColor : AppColors.greyShade600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

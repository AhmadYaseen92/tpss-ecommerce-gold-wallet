import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';

class ProductFilterBar extends StatelessWidget {
  final ProductCubit productCubit;
  const ProductFilterBar({super.key, required this.productCubit});

  static const List<String> categories = [
    'All',
    'Bullion',
    'Jewellery',
    'Coins',
  ];

  @override
  Widget build(BuildContext context) {
    String selectedCategory = "All";
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded ) {
           selectedCategory = state.category;}
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                isSelected
                                    ? AppColors.darkGold
                                    : AppColors.white,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (category == 'All') {
                                productCubit.loadProducts();
                              } else {
                                productCubit.filterProducts(category);
                              }
                            },
                            child: Text(
                              category,
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // The Algorithm for filtering products
                      },
                      icon: const Icon(Icons.tune),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // The Algorithm for sorting products
                      },
                      icon: const Icon(Icons.sort),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
      },
    );
  }
}

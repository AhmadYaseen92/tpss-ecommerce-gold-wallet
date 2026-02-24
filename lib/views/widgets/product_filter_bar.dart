import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/product_cubit/product_cubit.dart';

class ProductFilterBar extends StatefulWidget {

  const ProductFilterBar({super.key});

  @override
  State<ProductFilterBar> createState() => _ProductFilterBarState();
}

class _ProductFilterBarState extends State<ProductFilterBar> {
   String selectedCategory = 'All';
  final List<String> categories = ['All', 'Bullion', 'Jewellery', 'Coins'];


  @override
  Widget build(BuildContext context) {
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
                          isSelected ? AppColors.darkGold : AppColors.white,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                        onPressed: () {
                        setState(() {
                          if (category == 'All') {
                            selectedCategory = 'All';
                            context.read<ProductCubit>().loadProducts();
                          } else {  
                          selectedCategory = category;
                          context.read<ProductCubit>().filterProducts(
                          selectedCategory,
                          );
                        }
                        });
                        },
                      child: Text(
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                        category,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // The Algorithm for filtering products
                },
                icon: const Icon(Icons.tune),

                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: CircleBorder(),
                ),
              ),

              IconButton(
                onPressed: () {
                  // The Algorithm for sorting products
                },

                icon: const Icon(Icons.sort),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  shape: CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

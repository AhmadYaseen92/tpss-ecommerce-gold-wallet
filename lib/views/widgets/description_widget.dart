import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/product_item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';

class DescriptionWidget extends StatelessWidget {
  final ProductItemModel product;

  const DescriptionWidget({
    super.key,
    required this.product,
  });


  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkGrey,
              height: 1.6,
            ),
          )
      ],
    );
  }
}
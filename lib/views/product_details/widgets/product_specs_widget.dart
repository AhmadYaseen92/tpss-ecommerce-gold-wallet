import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class ProductSpecsWidget extends StatelessWidget {
  final String purity;
  final String weight;
  final String metal;

  const ProductSpecsWidget({
    required this.purity,
    required this.weight,
    required this.metal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _productSpecsCard(label: 'Purity', value: purity),
        const SizedBox(width: 10),
        _productSpecsCard(label: 'Weight', value: weight),
        const SizedBox(width: 10),
        _productSpecsCard(label: 'Metal', value: metal),
      ],
    );
  }

  Widget _productSpecsCard({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyShade2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppColors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

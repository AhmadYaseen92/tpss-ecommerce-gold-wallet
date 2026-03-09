import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class CurrencyCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String selectedCurrency;
  final List<String>? currencies;
  final String amountLabel;
  final ValueChanged<String>? onChanged;

  const CurrencyCard({
    required this.icon,
    required this.iconColor,
    required this.selectedCurrency,
    required this.currencies,
    required this.amountLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.greysShade2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18.0),
              ),
              const SizedBox(width: 6.0),
              Expanded(
                child: currencies != null
                    ? DropdownButton<String>(
                        value: selectedCurrency,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                          color: AppColors.black,
                        ),
                        items: currencies!
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) onChanged?.call(v);
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          selectedCurrency,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                            color: AppColors.black,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            amountLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
          ),
        ],
      ),
    );
  }
}

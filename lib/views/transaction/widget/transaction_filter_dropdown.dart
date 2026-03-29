import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isActive;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 7, 0),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primaryColor : AppColors.greysShade2,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(14),
          underline: const SizedBox(),
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: isActive ? AppColors.white : AppColors.grey,
          ),
          dropdownColor: AppColors.white,
          selectedItemBuilder: (context) => items.map((item) {
            final isCurrent = item == value;
            return Row(
              children: [
                if (isCurrent && isActive) const Icon(Icons.check_circle, size: 14, color: AppColors.white),
                if (isCurrent && isActive) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? AppColors.white : AppColors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
          items: items.map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.black,
                      fontWeight: item == value ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

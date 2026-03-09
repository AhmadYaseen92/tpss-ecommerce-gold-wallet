import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class NationalityDropdown extends StatelessWidget {
  final String selectedNationality;
  final ValueChanged<String> onChanged;

  const NationalityDropdown({
    super.key,
    required this.selectedNationality,
    required this.onChanged,
  });

  static const List<Map<String, String>> nationalities = [
    {'name': 'Jordanian', 'flag': '🇯🇴'},
    {'name': 'Emirati', 'flag': '🇦🇪'},
    {'name': 'Palestinian', 'flag': '🇵🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder, width: 1),
      ),
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(12),
        dropdownColor: AppColors.white,
        style: const TextStyle(
          color: AppColors.textColor,
          fontSize: 14,
        ),
        underline: const SizedBox(),
        value: selectedNationality,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.greyShade500,
        ),
        isExpanded: true,
        items: nationalities.map((e) {
          return DropdownMenuItem<String>(
            value: e['name'],
            child: Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text('${e['flag']} ${e['name']}'),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
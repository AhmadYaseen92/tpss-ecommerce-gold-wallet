import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';

class NationalityDropdown extends StatelessWidget {
  final String selectedNationality;
  final ValueChanged<String> onChanged;

  const NationalityDropdown({
    super.key,
    required this.selectedNationality,
    required this.onChanged,
  });

  static const List<Map<String, String>> nationalities = [
    {'name': 'Unknown', 'flag': '🏳️'},
    {'name': 'Jordanian', 'flag': '🇯🇴'},
    {'name': 'Emirati', 'flag': '🇦🇪'},
    {'name': 'Palestinian', 'flag': '🇵🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    final normalizedSelected = ProfileCubit.normalizeNationalityValue(selectedNationality);
    final hasSelected = nationalities.any((e) => e['name'] == normalizedSelected);
    final items = [
      ...nationalities,
      if (!hasSelected) {'name': normalizedSelected, 'flag': '🏳️'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(12),
        dropdownColor: palette.surface,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
        ),
        underline: const SizedBox(),
        value: hasSelected ? normalizedSelected : items.last['name'],
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: palette.textSecondary,
        ),
        isExpanded: true,
        items: items.map((e) {
          return DropdownMenuItem<String>(
            value: e['name'],
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: palette.primary,
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

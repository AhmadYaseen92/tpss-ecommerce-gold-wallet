import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/predefined_accounts_data.dart';

class PredefinedAccountSelector extends StatelessWidget {
  final String label;
  final List<PredefinedAccount> accounts;
  final int selectedIndex;
  final ValueChanged<int?> onChanged;
  final IconData icon;

  const PredefinedAccountSelector({
    super.key,
    required this.label,
    required this.accounts,
    required this.selectedIndex,
    required this.onChanged,
    this.icon = Icons.account_balance_wallet_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final selected = accounts[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: selectedIndex,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: palette.surface,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: palette.primary),
            border: const OutlineInputBorder(),
          ),
          selectedItemBuilder: (context) {
            return List.generate(
              accounts.length,
              (index) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  accounts[index].name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: palette.textPrimary),
                ),
              ),
            );
          },
          items: List.generate(
            accounts.length,
            (index) => DropdownMenuItem(
              value: index,
              child: Text(
                '${accounts[index].name} • ${accounts[index].subtitle}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: palette.textPrimary),
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 6),
        Text(selected.subtitle, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
      ],
    );
  }
}

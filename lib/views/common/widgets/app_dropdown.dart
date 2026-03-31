import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transfer_cubit/transfer_cubit.dart';

class AppDropdown extends StatelessWidget {
  final TransferCubit cubit;
  const AppDropdown({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: DropdownButton<int>(
        borderRadius: BorderRadius.circular(12),
        dropdownColor: palette.surface,
        value: cubit.selectedAssetIndex,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: List.generate(
          Asset.assets.length,
          (i) => DropdownMenuItem(
            value: i,
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: palette.primary),
                const SizedBox(width: 8),
                Text(
                  '${Asset.assets[i].name}  •  \$${Asset.assets[i].pricePerUnit.toStringAsFixed(2)}/g',
                ),
              ],
            ),
          ),
        ),
        onChanged: (v) {
          if (v != null) cubit.selectAsset(v);
        },
      ),
    );
  }
}

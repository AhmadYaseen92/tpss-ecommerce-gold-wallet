import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';

class AmountModeSelector extends StatelessWidget {
  final AmountInputMode selectedMode;
  final ValueChanged<AmountInputMode> onChanged;

  const AmountModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AmountInputMode>(
      segments: const [
        ButtonSegment(value: AmountInputMode.quantity, label: Text('Quantity')),
        ButtonSegment(value: AmountInputMode.weight, label: Text('Weight')),
        ButtonSegment(value: AmountInputMode.all, label: Text('All')),
      ],
      selected: {selectedMode},
      onSelectionChanged: (values) {
        onChanged(values.first);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';

class WalletActionsWidget extends StatelessWidget {
  const WalletActionsWidget({super.key, required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionItem(
              context, Icons.sell_outlined, 'Sell', AppRoutes.sellGoldRoute),
        ),
        Expanded(
          child: _buildActionItem(context, Icons.send_outlined, 'Transfer / Gift',
              AppRoutes.transferGiftRoute),
        ),
        Expanded(
          child: _buildActionItem(context, Icons.swap_horiz, 'Convert to Cash',
              AppRoutes.convertRoute),
        ),
      ],
    );
  }

  Widget _buildActionItem(
      BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: accentColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 32.0),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}


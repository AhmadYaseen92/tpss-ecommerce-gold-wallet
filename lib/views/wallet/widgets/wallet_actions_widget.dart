import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
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
              context, Icons.sell_outlined, 'Sell', AppRoutes.sellRoute),
        ),
        Expanded(
          child: _buildActionItem(context, Icons.wallet_giftcard, 'Transfer / Gift',
              AppRoutes.transferGiftRoute),
        ),
        // Expanded(
        //   child: _buildActionItem(context, CupertinoIcons.money_dollar, 'Convert ',
        //       AppRoutes.convertRoute),
        // ),
         Expanded(
          child: _buildActionItem(context, CupertinoIcons.bitcoin, 'Convert ',
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: accentColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowBlack,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


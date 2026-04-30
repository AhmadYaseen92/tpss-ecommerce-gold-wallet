import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';

class HomeQuickActionsWidget extends StatelessWidget {
  const HomeQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickActions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(context, Icons.wallet_sharp, AppLocalizations.of(context).buy, AppRoutes.productRoute),
            _buildActionItem(context, Icons.sell_outlined, AppLocalizations.of(context).sell, AppRoutes.sellRoute),
            _buildActionItem(context, Icons.wallet_giftcard, AppLocalizations.of(context).transfer, AppRoutes.transferGiftRoute),
            _buildActionItem(context, Icons.attach_money, AppLocalizations.of(context).convert, AppRoutes.convertRoute),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, String route) {
    final palette = context.appPalette;

    return GestureDetector(
      onTap: () {
        if (AppRoutes.productRoute == route) {
          Navigator.pushNamed(context, route);
        } else {
          Navigator.of(context, rootNavigator: true).pushNamed(route);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: palette.primary),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 32.0, color: palette.textPrimary),
          ),
          const SizedBox(height: 4.0),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

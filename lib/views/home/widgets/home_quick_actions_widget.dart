import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class HomeQuickActionsWidget extends StatelessWidget {
  const HomeQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(
              context,
              Icons.wallet_sharp,
              'Buy',
            ), //Icons.add_box
            _buildActionItem(
              context,
              Icons.sell_outlined,
              'Sell',
            ), //indeterminate_check_box
            _buildActionItem(context, Icons.swap_horiz, 'Transfer'),
            _buildActionItem(context, Icons.attach_money, 'Convert'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.primaryColor),
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
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

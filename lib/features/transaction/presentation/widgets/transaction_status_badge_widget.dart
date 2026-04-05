import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color dotColor = AppColors.grey;
    Color bgColor = AppColors.greyShade2;
    String label = 'Unknown';

    switch (status) {
      case 'completed':
        dotColor = AppColors.green;
        bgColor = AppColors.lightGreen;
        label = 'Completed';
        break;
      case 'pending':
        dotColor = AppColors.pendingOrange;
        bgColor = AppColors.lightOrange;
        label = 'Pending';
        break;
      case 'failed':
        dotColor = AppColors.red;
        bgColor = AppColors.lightRed;
        label = 'Failed';
        break;
      default:
        dotColor = AppColors.grey;
        bgColor = AppColors.greyShade2;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: dotColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

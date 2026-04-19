import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';

/// A reusable empty state widget for displaying empty pages, lists, or sections.
/// 
/// This widget can be used across the entire app for consistent empty state UI.
/// 
/// Example usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.shopping_cart_outlined,
///   title: 'Your Cart is Empty',
///   message: 'Start shopping to fill your cart!',
///   primaryButtonLabel: 'Start Shopping',
///   primaryButtonAction: () => Navigator.pushNamed(context, AppRoutes.productRoute),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display (e.g., Icons.shopping_cart_outlined)
  final IconData icon;

  /// The main title text
  final String title;

  /// The subtitle/message text
  final String message;


  /// Optional label for secondary button
  final String? secondaryButtonLabel;

  /// Optional callback for secondary button
  final VoidCallback? secondaryButtonAction;

  /// Background color for the icon container
  final Color iconBackgroundColor;

  /// Color of the icon itself
  final Color iconColor;

  /// Size of the icon container
  final double iconSize;

  /// Size of the icon itself
  final double iconIconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.secondaryButtonLabel,
    this.secondaryButtonAction,
    this.iconBackgroundColor = AppColors.luxuryIvory,
    this.iconColor = AppColors.darkGold,
    this.iconSize = 120,
    this.iconIconSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconIconSize,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
            ),
            const SizedBox(height: 12),

            // Message/Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyShade600,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 40),

            // Secondary Action Button (optional)
            if (secondaryButtonLabel != null && secondaryButtonAction != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: secondaryButtonAction,
                child: Text(
                  secondaryButtonLabel!,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

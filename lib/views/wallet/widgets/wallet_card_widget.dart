import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class WalletCardWidget extends StatelessWidget {
  final String walletName;
  final bool isVerified;
  final String weight;
  final String weightLabel;
  final String value;
  final String change;
  final IconData icon;

  const WalletCardWidget({
    super.key,
    required this.walletName,
    required this.isVerified,
    required this.weight,
    required this.weightLabel,
    required this.value,
    required this.change,
    required this.icon,
  });

  bool get _isPositive => change.startsWith('+');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.luxuryIvory, AppColors.white],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.primaryColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: Colors.white, size: 20.0),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    walletName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isVerified)
                    Container(
                      margin: const EdgeInsets.only(top: 2.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: AppColors.green.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        'VERIFIED',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Icon(Icons.more_vert, color: AppColors.darkGrey),
            ],
          ),
          const SizedBox(height: 16.0),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: weight,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                TextSpan(
                  text: '  $weightLabel',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(width: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: (_isPositive ? AppColors.green : AppColors.red)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: (_isPositive ? AppColors.green : AppColors.red)
                        .withAlpha(80),
                  ),
                ),
                child: Text(
                  change,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _isPositive ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          SizedBox(
            height: 42.0,
            child: CustomPaint(
              size: const Size(double.infinity, 42),
              painter: _WalletChartPainter(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletChartPainter extends CustomPainter {
  final Color color;

  const _WalletChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.55);
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.85,
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.38,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.50,
      size.height * 0.05,
      size.width * 0.58,
      size.height * 0.2,
      size.width * 0.65,
      size.height * 0.38,
    );
    path.cubicTo(
      size.width * 0.72,
      size.height * 0.55,
      size.width * 0.80,
      size.height * 0.75,
      size.width * 0.88,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.93,
      size.height * 0.35,
      size.width * 0.97,
      size.height * 0.25,
      size.width,
      size.height * 0.28,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';

class ProductImage extends StatelessWidget {
  static const String _fallbackImageUrl =
      'https://www.pamp.com/sites/pamp/files/2022-02/10g_1.png';

  final String imageUrl;
  final Color color;
  final bool is3D; // control whether to show 3D or image

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.color,
    this.is3D = false,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = Uri.tryParse(imageUrl.trim());
    final validNetworkUrl = parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        parsed.host.isNotEmpty;
    final finalUrl = validNetworkUrl ? imageUrl : _fallbackImageUrl;

    return Container(
      width: double.infinity,
      height: 300,
      color: Theme.of(context).scaffoldBackgroundColor,
      child:
          // is3D
          //     ? ModelViewer(
          //         src:"https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/GoldBar/glTF-Binary/GoldBar.glb",
          //         autoRotate: true,
          //         cameraControls: true,
          //         backgroundColor: Colors.white,
          //       )
          //     :
          Image.network(
            finalUrl,
            fit: BoxFit.fitHeight,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: color,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Image.network(
                _fallbackImageUrl,
                fit: BoxFit.fitHeight,
              );
            },
          ),
    );
  }
}

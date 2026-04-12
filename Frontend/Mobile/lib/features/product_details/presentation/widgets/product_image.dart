import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_server_image.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final bool is3D; // control whether to show 3D or image

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.is3D = false,
  });

  @override
  Widget build(BuildContext context) {
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
          AppServerImage(
            imageUrl: imageUrl,
            fit: BoxFit.fitHeight,
            width: double.infinity,
            height: 300,
          ),
    );
  }
}

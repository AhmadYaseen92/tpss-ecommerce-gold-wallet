import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
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
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.white,
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
            imageUrl,
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
              return Center(
                child: Icon(Icons.broken_image_rounded, color: color, size: 48),
              );
            },
          ),
    );
  }
}

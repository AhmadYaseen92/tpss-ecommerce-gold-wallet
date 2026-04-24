import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/utils/server_url_resolver.dart';

class AppServerImage extends StatelessWidget {
  const AppServerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIconSize = 24,
    this.backgroundColor,
    this.iconColor,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double placeholderIconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveServerUrl(imageUrl);
    final parsed = Uri.tryParse(resolved);
    final validNetworkUrl = parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https') &&
        parsed.host.isNotEmpty;

    final placeholder = _buildPlaceholder(context);
    if (!validNetworkUrl) {
      return placeholder;
    }

    Widget image = CachedNetworkImage(
      imageUrl: resolved,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final icon = iconColor ?? theme.colorScheme.onSurfaceVariant;
    Widget child = Container(
      width: width,
      height: height,
      color: bg,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: placeholderIconSize,
        color: icon,
      ),
    );
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}

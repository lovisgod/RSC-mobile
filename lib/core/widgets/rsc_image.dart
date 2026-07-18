import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'shimmer_box.dart';

/// Shows a real image from [imageUrl] when one is available, falling back to
/// [fallback] (typically a colored box + emoji) when the URL is null, empty,
/// or fails to load. [fallback] is always sized to [width]x[height] so
/// layout never jumps once the real image loads in.
class RscImage extends StatelessWidget {
  const RscImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget fallback;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final radius = borderRadius ?? BorderRadius.zero;

    if (url == null || url.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(width: width, height: height, child: fallback),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) =>
            ShimmerBox(width: width, height: height, radius: 0),
        errorWidget: (_, _, _) =>
            SizedBox(width: width, height: height, child: fallback),
      ),
    );
  }
}

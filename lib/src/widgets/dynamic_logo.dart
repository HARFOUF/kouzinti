import 'package:flutter/material.dart';

class DynamicLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const DynamicLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    // Choose logo based on theme
    final logoAsset = isDarkMode 
        ? 'assets/images/app_logo_light.png'
        : 'assets/images/app_logo.png';
    
    Widget logoWidget = Image.asset(
      logoAsset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(
          Icons.restaurant,
          size: 60,
          color: Colors.grey,
        );
      },
    );

    // Apply borderRadius if provided
    if (borderRadius != null) {
      logoWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
} 
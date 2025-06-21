import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultIcon = icon ?? Icons.error_outline;
    final defaultBackgroundColor = backgroundColor ?? Colors.red.shade50;
    final defaultTextColor = textColor ?? Colors.red.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: defaultTextColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            defaultIcon,
            size: 48.0,
            color: defaultTextColor,
          ),
          const SizedBox(height: 16.0),
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: defaultTextColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: defaultTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: defaultTextColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Connection Error',
      message: customMessage ?? 'Unable to connect to the server. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      backgroundColor: Colors.orange.shade50,
      textColor: Colors.orange.shade700,
    );
  }
}

class UploadErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const UploadErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Upload Failed',
      message: customMessage ?? 'Failed to upload image. Please check your connection and try again.',
      icon: Icons.cloud_upload_outlined,
      onRetry: onRetry,
      backgroundColor: Colors.red.shade50,
      textColor: Colors.red.shade700,
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const PermissionErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Permission Required',
      message: customMessage ?? 'Camera and storage permissions are required to upload images. Please grant permissions in settings.',
      icon: Icons.security,
      onRetry: onRetry,
      backgroundColor: Colors.blue.shade50,
      textColor: Colors.blue.shade700,
    );
  }
} 
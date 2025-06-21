import 'package:flutter/material.dart';
import 'package:kouzinti/src/constants/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final bool showAnimation;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onActionPressed,
    this.actionText,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAnimation)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: iconColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor ?? AppColors.primary,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onActionPressed != null && actionText != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                actionText!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onBrowseDishes;

  const EmptyCartWidget({
    super.key,
    this.onBrowseDishes,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Your Cart is Empty',
      message: 'Start exploring delicious dishes and add them to your cart!',
      icon: Icons.shopping_cart_outlined,
      iconColor: Colors.orange.shade300,
      backgroundColor: Colors.orange.shade50,
      onActionPressed: onBrowseDishes,
      actionText: 'Browse Dishes',
    );
  }
}

class EmptyDishesWidget extends StatelessWidget {
  final VoidCallback? onAddDish;

  const EmptyDishesWidget({
    super.key,
    this.onAddDish,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Dishes Yet',
      message: 'Start by adding your first delicious dish to showcase your culinary skills!',
      icon: Icons.restaurant_outlined,
      iconColor: Colors.green.shade300,
      backgroundColor: Colors.green.shade50,
      onActionPressed: onAddDish,
      actionText: 'Add First Dish',
    );
  }
}

class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback? onBrowseDishes;

  const EmptyOrdersWidget({
    super.key,
    this.onBrowseDishes,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Orders Yet',
      message: 'Your order history will appear here once you place your first order.',
      icon: Icons.receipt_long_outlined,
      iconColor: Colors.blue.shade300,
      backgroundColor: Colors.blue.shade50,
      onActionPressed: onBrowseDishes,
      actionText: 'Browse Dishes',
    );
  }
}

class EmptySearchResultsWidget extends StatelessWidget {
  final String searchTerm;

  const EmptySearchResultsWidget({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      message: 'No dishes found for "$searchTerm". Try searching with different keywords.',
      icon: Icons.search_off_outlined,
      iconColor: Colors.grey.shade400,
      backgroundColor: Colors.grey.shade50,
    );
  }
}

class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 
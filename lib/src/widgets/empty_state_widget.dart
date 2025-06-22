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
  final Widget? customIcon;

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
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? Colors.white,
            (backgroundColor ?? Colors.white).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAnimation)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value.clamp(0.0, 1.0),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            (iconColor ?? AppColors.primary).withOpacity(0.2),
                            (iconColor ?? AppColors.primary).withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (iconColor ?? AppColors.primary).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: customIcon ?? Icon(
                        icon,
                        size: 48,
                        color: iconColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    (iconColor ?? AppColors.primary).withOpacity(0.2),
                    (iconColor ?? AppColors.primary).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: customIcon ?? Icon(
                icon,
                size: 48,
                color: iconColor ?? AppColors.primary,
              ),
            ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value.clamp(0.0, 1.0))),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value.clamp(0.0, 1.0))),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          if (onActionPressed != null && actionText != null) ...[
            const SizedBox(height: 32),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onActionPressed,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          child: Text(
                            actionText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
      message: 'Start exploring delicious dishes and add them to your cart to begin your culinary journey!',
      icon: Icons.shopping_cart_outlined,
      iconColor: Colors.orange.shade400,
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
      message: 'Start by adding your first delicious dish to showcase your culinary skills and attract customers!',
      icon: Icons.restaurant_outlined,
      iconColor: Colors.green.shade400,
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
      message: 'Your order history will appear here once you place your first order. Start exploring delicious dishes!',
      icon: Icons.receipt_long_outlined,
      iconColor: Colors.blue.shade400,
      backgroundColor: Colors.blue.shade50,
      onActionPressed: onBrowseDishes,
      actionText: 'Browse Dishes',
    );
  }
}

class EmptyIncomingOrdersWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyIncomingOrdersWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Incoming Orders',
      message: 'Great things take time! Keep cooking delicious dishes and promoting your culinary skills. Orders will start coming in soon!',
      icon: Icons.restaurant_menu_outlined,
      iconColor: Colors.purple.shade400,
      backgroundColor: Colors.purple.shade50,
      onActionPressed: onRefresh,
      actionText: 'Refresh',
      customIcon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 48,
            color: Colors.purple.shade400,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.purple.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_outlined,
                size: 10,
                color: Colors.purple.shade600,
              ),
            ),
          ),
        ],
      ),
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
      message: 'No dishes found for "$searchTerm". Try searching with different keywords or browse our categories.',
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
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.red.shade50.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.red.shade200,
                  Colors.red.shade100,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.red.shade600,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade500,
                    Colors.red.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 
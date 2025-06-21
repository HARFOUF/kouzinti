import 'package:flutter/material.dart';
import 'package:kouzinty/src/models/dish_model.dart';
import 'package:kouzinty/src/constants/app_colors.dart';
import 'package:kouzinty/src/services/cart_service.dart';
import 'package:kouzinty/src/services/auth_service.dart';
import 'package:provider/provider.dart';

class DishCard extends StatelessWidget {
  final DishModel dish;
  final VoidCallback? onTap;
  final bool showChefName;
  final bool canAddToCart;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
    this.showChefName = true,
    this.canAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section - Flexible height
                AspectRatio(
                  aspectRatio: 1.2,
                  child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                      ? Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.0),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16.0),
                            ),
                            child: Image.network(
                              dish.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            ),
                          ),
                        )
                      : _buildPlaceholderImage(),
                ),
                // Content Section - Flexible height
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dish Name
                        Text(
                          dish.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Category
                        Text(
                          dish.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showChefName) ...[
                          const SizedBox(height: 2),
                          FutureBuilder<String>(
                            future: _getChefName(dish.chefId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  'by ${snapshot.data}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                        const Spacer(),
                        // Price and Action Button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                '\$24${dish.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 1,
                              child: canAddToCart
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          Provider.of<CartService>(context, listen: false).addItem(dish);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${dish.name} added to cart'),
                                              duration: const Duration(seconds: 2),
                                              backgroundColor: AppColors.primary,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              action: SnackBarAction(
                                                label: 'UNDO',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  Provider.of<CartService>(context, listen: false).removeSingleItem(dish.id);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Your dish',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
        color: Colors.grey,
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 32,
          color: Colors.white70,
        ),
      ),
    );
  }

  Future<String> _getChefName(String chefId) async {
    try {
      final authService = AuthService();
      final chef = await authService.getUserById(chefId);
      return chef?.name ?? 'Unknown Chef';
    } catch (e) {
      return 'Unknown Chef';
    }
  }
} 
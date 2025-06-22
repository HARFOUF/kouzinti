import 'package:flutter/material.dart';
import 'package:kouzinti/src/models/dish_model.dart';
import 'package:kouzinti/src/constants/app_colors.dart';
import 'package:kouzinti/src/services/cart_service.dart';
import 'package:kouzinti/src/services/auth_service.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section - Fixed aspect ratio
            AspectRatio(
              aspectRatio: 16 / 10, // More reasonable aspect ratio
              child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                      child: Image.network(
                        dish.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
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
                    )
                  : _buildPlaceholderImage(),
            ),
            
            // Content Section - Using Flexible instead of Expanded
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important: minimize space usage
                  children: [
                    // Dish Name
                    Text(
                      dish.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
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
                    
                    // Chef Name (conditional)
                    if (showChefName) ...[
                      const SizedBox(height: 4),
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
                          return const SizedBox(height: 14); // Placeholder height
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Price and Add to Cart Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${dish.price.toStringAsFixed(0)} DZD',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (canAddToCart)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () => _addToCart(context),
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 16,
                              ),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          )
                        else
                          Container(
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
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
            Provider.of<CartService>(context, listen: false)
                .removeSingleItem(dish.id);
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.restaurant, size: 32, color: Colors.white70),
      ),
    );
  }

  Future<String> _getChefName(String chefId) async {
    try {
      final authService = AuthService();
      final chef = await authService.getUserById(chefId);
      return chef?.name ?? 'Unknown Chef';
    } catch (_) {
      return 'Unknown Chef';
    }
  }
}
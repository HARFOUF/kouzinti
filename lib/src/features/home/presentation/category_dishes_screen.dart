import 'package:flutter/material.dart';
import 'package:kouzinty/src/models/dish_model.dart';
import 'package:kouzinty/src/models/category_model.dart';
import 'package:kouzinty/src/services/category_service.dart';
import 'package:kouzinty/src/services/auth_service.dart';
import 'package:kouzinty/src/widgets/dish_card.dart';
import 'package:kouzinty/src/widgets/error_widget.dart';
import 'package:kouzinty/src/widgets/empty_state_widget.dart';
import 'package:kouzinty/src/constants/app_colors.dart';
import 'package:kouzinty/src/features/home/presentation/chef_profile_screen.dart';

class CategoryDishesScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDishesScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final categoryService = CategoryService();
    final authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: category.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      category.color,
                      category.color.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                category.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          StreamBuilder<List<DishModel>>(
            stream: categoryService.getDishesByCategory(category.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: LoadingStateWidget(
                    message: 'Loading category dishes...',
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: NetworkErrorWidget(
                    customMessage: 'Failed to load dishes: ${snapshot.error}',
                    onRetry: () {
                      // The stream will automatically retry when the widget rebuilds
                    },
                  ),
                );
              }

              final dishes = snapshot.data ?? [];

              if (dishes.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyStateWidget(
                    title: 'No Dishes Found',
                    message: 'No dishes available in ${category.name} category yet.',
                    icon: category.icon,
                    iconColor: category.color,
                    backgroundColor: category.color,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dish = dishes[index];
                      return FutureBuilder<String>(
                        future: _getChefName(dish.chefId),
                        builder: (context, chefSnapshot) {
                          return DishCard(
                            dish: dish,
                            onTap: () {
                              // Navigate to chef profile
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChefProfileScreen(
                                    chefId: dish.chefId,
                                    chefName: chefSnapshot.data ?? 'Chef',
                                  ),
                                ),
                              );
                            },
                            canAddToCart: true,
                          );
                        },
                      );
                    },
                    childCount: dishes.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
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
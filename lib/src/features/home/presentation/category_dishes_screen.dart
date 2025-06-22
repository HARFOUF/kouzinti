import 'package:flutter/material.dart';
import 'package:kouzinti/src/models/dish_model.dart';
import 'package:kouzinti/src/models/category_model.dart';
import 'package:kouzinti/src/services/category_service.dart';
import 'package:kouzinti/src/services/auth_service.dart';
import 'package:kouzinti/src/widgets/dish_card.dart';
import 'package:kouzinti/src/widgets/error_widget.dart';
import 'package:kouzinti/src/widgets/empty_state_widget.dart';
import 'package:kouzinti/src/constants/app_colors.dart';
import 'package:kouzinti/src/features/home/presentation/chef_profile_screen.dart';
import 'package:kouzinti/src/models/user_model.dart';

class CategoryDishesScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDishesScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final categoryService = CategoryService();

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        size: 80,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'About ${category.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<List<DishModel>>(
            stream: categoryService.getDishesByCategory(category.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: NetworkErrorWidget(
                    customMessage: 'Failed to load dishes: ${snapshot.error}',
                    onRetry: () {},
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

              return FutureBuilder<UserModel?>(
                future: _getCurrentUser(),
                builder: (context, userSnapshot) {
                  // Show loading while fetching user data
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // Show error if user data fetch fails
                  if (userSnapshot.hasError) {
                    return SliverFillRemaining(
                      child: NetworkErrorWidget(
                        customMessage: 'Failed to load user data: ${userSnapshot.error}',
                        onRetry: () {
                          // Force rebuild to retry
                        },
                      ),
                    );
                  }

                  // Only render dishes after we have user data
                  final currentUser = userSnapshot.data;
                  
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200.0,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.62, // Fixed: Increased height for cards
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dish = dishes[index];
                          final isCurrentUserChef = currentUser?.id == dish.chefId;
                          return FutureBuilder<String>(
                            future: _getChefName(dish.chefId),
                            builder: (context, chefSnapshot) {
                              return DishCard(
                                dish: dish,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChefProfileScreen(
                                        chefId: dish.chefId,
                                        chefName: chefSnapshot.data ?? 'Chef',
                                      ),
                                    ),
                                  );
                                },
                                canAddToCart: !isCurrentUserChef, // Chef can't order their own dishes
                              );
                            },
                          );
                        },
                        childCount: dishes.length,
                      ),
                    ),
                  );
                },
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

  Future<UserModel?> _getCurrentUser() async {
    final authService = AuthService();
    return await authService.getCurrentUser();
  }
}
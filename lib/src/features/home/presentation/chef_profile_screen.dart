import 'package:flutter/material.dart';
import 'package:kouzinty/src/models/dish_model.dart';
import 'package:kouzinty/src/models/user_model.dart';
import 'package:kouzinty/src/services/dish_service.dart';
import 'package:kouzinty/src/services/auth_service.dart';
import 'package:kouzinty/src/widgets/dish_card.dart';
import 'package:kouzinty/src/widgets/error_widget.dart';
import 'package:kouzinty/src/widgets/empty_state_widget.dart';
import 'package:kouzinty/src/constants/app_colors.dart';

class ChefProfileScreen extends StatelessWidget {
  final String chefId;
  final String chefName;

  const ChefProfileScreen({
    super.key,
    required this.chefId,
    required this.chefName,
  });

  @override
  Widget build(BuildContext context) {
    final dishService = DishService();
    final authService = AuthService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                chefName,
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
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant,
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
                'Discover delicious dishes by $chefName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          StreamBuilder<List<DishModel>>(
            stream: dishService.getChefDishes(chefId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: LoadingStateWidget(
                    message: 'Loading chef dishes...',
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
                return const SliverFillRemaining(
                  child: EmptyStateWidget(
                    title: 'No Dishes Available',
                    message: 'This chef hasn\'t added any dishes yet.',
                    icon: Icons.restaurant_outlined,
                    iconColor: Colors.grey,
                    backgroundColor: Colors.grey,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dish = dishes[index];
                      return FutureBuilder<UserModel?>(
                        future: authService.getCurrentUser(),
                        builder: (context, userSnapshot) {
                          final currentUser = userSnapshot.data;
                          final isCurrentUserChef = currentUser?.id == chefId;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                            child: DishCard(
                              dish: dish,
                              showChefName: true, // Show chef name on chef's page
                              onTap: () {
                                // Navigate to dish detail if needed
                              },
                              canAddToCart: !isCurrentUserChef, // Chef can't order their own dishes
                            ),
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
        ],
      ),
    );
  }
} 
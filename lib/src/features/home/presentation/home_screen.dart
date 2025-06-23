import 'package:flutter/material.dart';
import 'package:kouzinti/src/features/cart/presentation/cart_screen.dart';
import 'package:kouzinti/src/features/profile/presentation/profile_screen.dart';
import 'package:kouzinti/src/features/home/presentation/chef_profile_screen.dart';
import 'package:kouzinti/src/features/home/presentation/category_dishes_screen.dart';
import 'package:kouzinti/src/models/dish_model.dart';
import 'package:kouzinti/src/models/user_model.dart';
import 'package:kouzinti/src/models/category_model.dart';
import 'package:kouzinti/src/services/dish_service.dart';
import 'package:kouzinti/src/services/auth_service.dart';
import 'package:kouzinti/src/services/category_service.dart';
import 'package:kouzinti/src/widgets/dish_card.dart';
import 'package:kouzinti/src/widgets/category_card.dart';
import 'package:kouzinti/src/widgets/empty_state_widget.dart';
import 'package:kouzinti/src/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DishService _dishService = DishService();
  final AuthService _authService = AuthService();
  final CategoryService _categoryService = CategoryService();
  
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Kouzinti',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _authService.getCurrentUser(),
        builder: (context, userSnapshot) {
          final currentUser = userSnapshot.data;
          
          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search dishes, categories...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.primary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              
              // Main Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Force refresh of all streams
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: _isSearching
                      ? _buildSearchResults(currentUser)
                      : _buildMainContent(currentUser),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(UserModel? currentUser) {
    return StreamBuilder<List<DishModel>>(
      stream: _dishService.searchDishes(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingStateWidget(
              message: 'Searching dishes...',
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: ErrorStateWidget(
              message: 'Failed to search dishes: ${snapshot.error}',
              onRetry: () {
                // Stream will automatically retry
              },
            ),
          );
        }

        final searchResults = snapshot.data ?? [];
        
        if (searchResults.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              title: 'No Results Found',
              message: 'Try searching for different dishes or categories.',
              icon: Icons.search_off_outlined,
              iconColor: Colors.grey.shade400,
              backgroundColor: Colors.grey.shade50,
              showAnimation: false,
            ),
          );
        }

        return FutureBuilder<UserModel?>(
          future: _authService.getCurrentUser(),
          builder: (context, userSnapshot) {
            // Show loading while fetching user data
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error if user data fetch fails
            if (userSnapshot.hasError) {
              return Center(
                child: ErrorStateWidget(
                  message: 'Failed to load user data: ${userSnapshot.error}',
                  onRetry: () {
                    // Force rebuild to retry
                  },
                ),
              );
            }

            // Only render search results after we have user data
            final currentUser = userSnapshot.data;
            
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Search Results (${searchResults.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7, // Fixed: Increased height for cards
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dish = searchResults[index];
                        final isCurrentUserChef = currentUser?.id == dish.chefId;
                        return DishCard(
                          dish: dish,
                          onTap: () async {
                            // Fetch the actual chef's name
                            final chef = await _authService.getUserById(dish.chefId);
                            final chefName = chef != null ? '${chef.firstName} ${chef.lastName}'.trim() : 'Unknown Chef';
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChefProfileScreen(
                                    chefId: dish.chefId,
                                    chefName: chefName,
                                  ),
                                ),
                              );
                            }
                          },
                          canAddToCart: !isCurrentUserChef, // Chef can't order their own dishes
                        );
                      },
                      childCount: searchResults.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent(UserModel? currentUser) {
    return CustomScrollView(
      slivers: [
        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Discover Delicious Dishes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // Categories Section
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<List<CategoryModel>>(
            stream: _categoryService.getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: ErrorStateWidget(
                    message: 'Failed to load categories: ${snapshot.error}',
                    onRetry: () {
                      // Stream will automatically retry
                    },
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyStateWidget(
                    title: 'No Categories Available',
                    message: 'Categories will appear here once they are added.',
                    icon: Icons.category_outlined,
                    iconColor: Colors.grey,
                    backgroundColor: Colors.grey[50],
                    showAnimation: false,
                  ),
                );
              }

              return SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 16),
                      child: CategoryCard(
                        category: category,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CategoryDishesScreen(category: category),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // All Dishes Section
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'All Dishes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        StreamBuilder<List<DishModel>>(
          stream: _dishService.getAllDishes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ErrorStateWidget(
                    message: 'Failed to load dishes: ${snapshot.error}',
                    onRetry: () {
                      // Stream will automatically retry
                    },
                  ),
                ),
              );
            }

            final allDishes = snapshot.data ?? [];
            
            if (allDishes.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: EmptyStateWidget(
                    title: 'No Dishes Available',
                    message: 'Our chefs are preparing delicious dishes for you! Check back soon or try refreshing the page.',
                    icon: Icons.restaurant_outlined,
                    iconColor: Colors.orange.shade400,
                    backgroundColor: Colors.orange.shade50,
                    onActionPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    actionText: 'Refresh',
                  ),
                ),
              );
            }

            return FutureBuilder<UserModel?>(
              future: _authService.getCurrentUser(),
              builder: (context, userSnapshot) {
                // Show loading while fetching user data
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                // Show error if user data fetch fails
                if (userSnapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ErrorStateWidget(
                        message: 'Failed to load user data: ${userSnapshot.error}',
                        onRetry: () {
                          // Force rebuild to retry
                        },
                      ),
                    ),
                  );
                }

                // Only render dishes after we have user data
                final currentUser = userSnapshot.data;
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.62, // Fixed: Increased height for cards
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dish = allDishes[index];
                        final isCurrentUserChef = currentUser?.id == dish.chefId;
                        return DishCard(
                          dish: dish,
                          onTap: () async {
                            // Fetch the actual chef's name
                            final chef = await _authService.getUserById(dish.chefId);
                            final chefName = chef != null ? '${chef.firstName} ${chef.lastName}'.trim() : 'Unknown Chef';
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChefProfileScreen(
                                    chefId: dish.chefId,
                                    chefName: chefName,
                                  ),
                                ),
                              );
                            }
                          },
                          canAddToCart: !isCurrentUserChef, // Chef can't order their own dishes
                        );
                      },
                      childCount: allDishes.length,
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
    );
  }
}
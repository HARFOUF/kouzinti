import 'package:flutter/material.dart';
import 'package:kouzinti/src/models/dish_model.dart';
import 'package:kouzinti/src/services/dish_service.dart';
import 'package:kouzinti/src/services/category_service.dart';
import 'package:kouzinti/src/models/category_model.dart';

class EditDishScreen extends StatefulWidget {
  final DishModel? dish;

  const EditDishScreen({super.key, this.dish});

  @override
  State<EditDishScreen> createState() => _EditDishScreenState();
}

class _EditDishScreenState extends State<EditDishScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;
  final DishService _dishService = DishService();
  final CategoryService _categoryService = CategoryService();

  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dish?.name ?? '');
    _descriptionController = TextEditingController(text: widget.dish?.description ?? '');
    _priceController = TextEditingController(text: widget.dish?.price.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.dish?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.dish == null) {
        // Adding new dish
        await _dishService.createDish(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          category: _selectedCategory!.name,
          categoryId: _selectedCategory!.id,
          imageUrl: _imageUrlController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dish added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Updating existing dish
        await _dishService.updateDish(
          dishId: widget.dish!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          category: _selectedCategory!.name,
          categoryId: _selectedCategory!.id,
          imageUrl: _imageUrlController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dish updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving dish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish == null ? 'Add Dish' : 'Edit Dish'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image URL Field
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Dish Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a dish name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              StreamBuilder<List<CategoryModel>>(
                stream: _categoryService.getAllCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final categories = snapshot.data!;
                  if (_selectedCategory == null && widget.dish != null) {
                    _selectedCategory = categories.firstWhere(
                      (cat) => cat.name == widget.dish!.category,
                      orElse: () => categories.first,
                    );
                  }
                  return DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    items: categories
                        .map((cat) => DropdownMenuItem<CategoryModel>(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(cat.icon, color: cat.color),
                                  const SizedBox(width: 8),
                                  Text(cat.name),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (DZD)',
                  border: OutlineInputBorder(),
                  prefixText: 'DZD ',
                  hintText: 'Enter price in DZD',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveForm,
                child: Text(widget.dish == null ? 'Add Dish' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
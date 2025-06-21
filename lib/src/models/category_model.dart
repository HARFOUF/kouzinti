import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CategoryModel(
      id: documentId,
      name: data['name'] ?? '',
      icon: _getIconFromString(data['icon'] ?? 'restaurant'),
      color: _getColorFromString(data['color'] ?? '#4CAF50'),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon.codePoint.toString(),
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'description': description,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'cake':
        return Icons.cake;
      case 'local_dining':
        return Icons.local_dining;
      case 'coffee':
        return Icons.coffee;
      case 'local_bar':
        return Icons.local_bar;
      case 'icecream':
        return Icons.icecream;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'ramen_dining':
        return Icons.ramen_dining;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'dinner_dining':
        return Icons.dinner_dining;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'set_meal':
        return Icons.set_meal;
      case 'rice_bowl':
        return Icons.rice_bowl;
      default:
        return Icons.restaurant;
    }
  }

  static Color _getColorFromString(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.green;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 
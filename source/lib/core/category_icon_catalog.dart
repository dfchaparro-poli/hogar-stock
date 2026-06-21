import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

class CategoryIconCatalog {
  static const fallbackKey = 'other';

  static const options = <CategoryIconOption>[
    CategoryIconOption(
      key: 'market',
      label: 'Mercado',
      icon: Icons.shopping_basket_outlined,
    ),
    CategoryIconOption(
      key: 'cleaning',
      label: 'Limpieza',
      icon: Icons.cleaning_services_outlined,
    ),
    CategoryIconOption(
      key: 'personal_care',
      label: 'Aseo',
      icon: Icons.spa_outlined,
    ),
    CategoryIconOption(
      key: 'medicine',
      label: 'Medicamentos',
      icon: Icons.medication_outlined,
    ),
    CategoryIconOption(
      key: 'cold',
      label: 'Refrigerados',
      icon: Icons.ac_unit_outlined,
    ),
    CategoryIconOption(
      key: 'food',
      label: 'Alimentos',
      icon: Icons.restaurant_outlined,
    ),
    CategoryIconOption(
      key: 'drink',
      label: 'Bebidas',
      icon: Icons.local_drink_outlined,
    ),
    CategoryIconOption(
      key: 'pets',
      label: 'Mascotas',
      icon: Icons.pets_outlined,
    ),
    CategoryIconOption(key: 'home', label: 'Hogar', icon: Icons.home_outlined),
    CategoryIconOption(
      key: fallbackKey,
      label: 'Otros',
      icon: Icons.category_outlined,
    ),
  ];

  static String keyFor(Category? category) {
    if (category == null) {
      return fallbackKey;
    }
    return normalizeKey(category.iconKey) ?? suggestedKeyForName(category.name);
  }

  static IconData iconFor(Category? category) {
    return iconForKey(keyFor(category));
  }

  static IconData iconForKey(String? key) {
    return optionForKey(key).icon;
  }

  static CategoryIconOption optionForKey(String? key) {
    final normalized = normalizeKey(key) ?? fallbackKey;
    return options.firstWhere(
      (option) => option.key == normalized,
      orElse: () => options.last,
    );
  }

  static String suggestedKeyForName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.contains('mercado')) {
      return 'market';
    }
    if (normalized.contains('limpieza')) {
      return 'cleaning';
    }
    if (normalized.contains('aseo')) {
      return 'personal_care';
    }
    if (normalized.contains('medicamento') || normalized.contains('medicina')) {
      return 'medicine';
    }
    if (normalized.contains('refrigerado') ||
        normalized.contains('frio') ||
        normalized.contains('frío')) {
      return 'cold';
    }
    if (normalized.contains('alimento') || normalized.contains('comida')) {
      return 'food';
    }
    if (normalized.contains('bebida')) {
      return 'drink';
    }
    if (normalized.contains('mascota')) {
      return 'pets';
    }
    if (normalized.contains('hogar') || normalized.contains('casa')) {
      return 'home';
    }
    return fallbackKey;
  }

  static String? normalizeKey(String? key) {
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    final normalized = key.trim();
    return options.any((option) => option.key == normalized)
        ? normalized
        : null;
  }
}

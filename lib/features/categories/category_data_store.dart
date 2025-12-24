import 'package:flutter/material.dart';

/// Item Model for persistence
class CategoryItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final DateTime date;
  final String source; // 'manual', 'voice', 'ocr'

  CategoryItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.date,
    this.source = 'manual',
  });

  double get totalPrice => quantity * unitPrice;
}

/// Category Model for persistence
class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  double totalAmount;
  final List<CategoryItem> items;
  final bool isMain;

  CategoryData({
    required this.name,
    required this.icon,
    this.color = const Color(0xFF1976D2),
    this.totalAmount = 0,
    List<CategoryItem>? items,
    this.isMain = false,
  }) : items = items ?? [];

  void addItem(CategoryItem item) {
    items.add(item);
    totalAmount += item.totalPrice;
  }

  void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      totalAmount -= items[index].totalPrice;
      items.removeAt(index);
    }
  }

  void recalculateTotal() {
    totalAmount = items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}

/// Singleton data store for category persistence
class CategoryDataStore {
  static final CategoryDataStore _instance = CategoryDataStore._internal();
  factory CategoryDataStore() => _instance;
  CategoryDataStore._internal() {
    _initMainCategories();
  }

  final List<CategoryData> _mainCategories = [];
  final List<CategoryData> _customCategories = [];

  List<CategoryData> get mainCategories => _mainCategories;
  List<CategoryData> get customCategories => _customCategories;
  List<CategoryData> get allCategories => [..._mainCategories, ..._customCategories];

  void _initMainCategories() {
    if (_mainCategories.isEmpty) {
      _mainCategories.addAll([
        CategoryData(name: 'Shopping', icon: Icons.shopping_bag, isMain: true),
        CategoryData(name: 'Food & Drinks', icon: Icons.restaurant, isMain: true),
        CategoryData(name: 'Bills', icon: Icons.receipt_long, isMain: true),
        CategoryData(name: 'Health', icon: Icons.local_hospital, isMain: true),
      ]);
    }
  }

  void addCustomCategory(CategoryData category) {
    _customCategories.add(category);
  }

  void removeCustomCategory(int index) {
    if (index >= 0 && index < _customCategories.length) {
      _customCategories.removeAt(index);
    }
  }

  CategoryData? findCategory(String name) {
    for (var cat in _mainCategories) {
      if (cat.name == name) return cat;
    }
    for (var cat in _customCategories) {
      if (cat.name == name) return cat;
    }
    return null;
  }

  void addItemToCategory(String categoryName, CategoryItem item) {
    final category = findCategory(categoryName);
    category?.addItem(item);
  }

  void removeItemFromCategory(String categoryName, int itemIndex) {
    final category = findCategory(categoryName);
    category?.removeItem(itemIndex);
  }
}

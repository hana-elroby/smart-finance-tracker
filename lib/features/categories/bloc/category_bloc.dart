import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class CategoryEvent {}

class AddCategory extends CategoryEvent {
  final String name;
  final IconData icon;
  AddCategory({required this.name, required this.icon});
}

class DeleteCategory extends CategoryEvent {
  final String name;
  DeleteCategory(this.name);
}

class LoadCategories extends CategoryEvent {}

// State
class CategoryState {
  final List<Map<String, dynamic>> customCategories;
  
  CategoryState({this.customCategories = const []});
  
  CategoryState copyWith({List<Map<String, dynamic>>? customCategories}) {
    return CategoryState(
      customCategories: customCategories ?? this.customCategories,
    );
  }
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  static const String _storageKey = 'custom_categories';
  
  CategoryBloc() : super(CategoryState()) {
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadCategories>(_onLoadCategories);
    
    // Auto-load categories on creation
    add(LoadCategories());
  }
  
  // Icon mapping for persistence
  static final Map<int, IconData> _iconMap = {
    Icons.restaurant.codePoint: Icons.restaurant,
    Icons.shopping_bag.codePoint: Icons.shopping_bag,
    Icons.receipt.codePoint: Icons.receipt,
    Icons.favorite.codePoint: Icons.favorite,
    Icons.directions_car.codePoint: Icons.directions_car,
    Icons.movie.codePoint: Icons.movie,
    Icons.school.codePoint: Icons.school,
    Icons.sports_esports.codePoint: Icons.sports_esports,
    Icons.pets.codePoint: Icons.pets,
    Icons.flight.codePoint: Icons.flight,
    Icons.home.codePoint: Icons.home,
    Icons.work.codePoint: Icons.work,
    Icons.fitness_center.codePoint: Icons.fitness_center,
    Icons.music_note.codePoint: Icons.music_note,
    Icons.book.codePoint: Icons.book,
    Icons.coffee.codePoint: Icons.coffee,
    Icons.local_gas_station.codePoint: Icons.local_gas_station,
    Icons.phone_android.codePoint: Icons.phone_android,
    Icons.wifi.codePoint: Icons.wifi,
    Icons.category.codePoint: Icons.category,
  };
  
  Future<void> _saveCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((cat) => {
      'name': cat['name'],
      'iconCode': (cat['icon'] as IconData).codePoint,
      'isDefault': cat['isDefault'] ?? false,
    }).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
  
  Future<List<Map<String, dynamic>>> _loadCategoriesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((item) {
      final iconCode = item['iconCode'] as int;
      return {
        'name': item['name'],
        'icon': _iconMap[iconCode] ?? Icons.category,
        'isDefault': item['isDefault'] ?? false,
      };
    }).toList();
  }
  
  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    final categories = await _loadCategoriesFromStorage();
    emit(state.copyWith(customCategories: categories));
  }
  
  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    final newCategory = {
      'name': event.name,
      'icon': event.icon,
      'isDefault': false,
    };
    
    final updatedList = [...state.customCategories, newCategory];
    emit(state.copyWith(customCategories: updatedList));
    
    // Save to SharedPreferences
    await _saveCategories(updatedList);
  }
  
  void _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) async {
    final updatedList = state.customCategories
        .where((cat) => cat['name'] != event.name)
        .toList();
    emit(state.copyWith(customCategories: updatedList));
    
    // Save to SharedPreferences
    await _saveCategories(updatedList);
  }
}

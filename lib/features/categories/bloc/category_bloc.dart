import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

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
  CategoryBloc() : super(CategoryState()) {
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }
  
  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) {
    final newCategory = {
      'name': event.name,
      'icon': event.icon,
      'isDefault': false,
    };
    
    final updatedList = [...state.customCategories, newCategory];
    emit(state.copyWith(customCategories: updatedList));
  }
  
  void _onDeleteCategory(DeleteCategory event, Emitter<CategoryState> emit) {
    final updatedList = state.customCategories
        .where((cat) => cat['name'] != event.name)
        .toList();
    emit(state.copyWith(customCategories: updatedList));
  }
}

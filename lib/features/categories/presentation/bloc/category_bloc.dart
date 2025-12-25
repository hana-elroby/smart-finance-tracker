// Category Bloc - منطق الفئات
// Handles all category-related business logic with API

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/category_api_service.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryApiService _categoryService = CategoryApiService();

  CategoryBloc() : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<SelectCategory>(_onSelectCategory);
  }

  // Load categories
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));

    try {
      final result = await _categoryService.getCategories();

      if (result.isSuccess) {
        emit(state.copyWith(
          status: CategoryStatus.loaded,
          categories: result.categories,
        ));
      } else {
        emit(state.copyWith(
          status: CategoryStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: 'Failed to load categories: $e',
      ));
    }
  }

  // Create category
  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.creating));

    try {
      final result = await _categoryService.createCategory(event.name);

      if (result.isSuccess && result.category != null) {
        emit(state.copyWith(
          status: CategoryStatus.loaded,
          categories: [...state.categories, result.category!],
          successMessage: 'Category created successfully',
        ));
      } else {
        emit(state.copyWith(
          status: CategoryStatus.loaded,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.loaded,
        errorMessage: 'Failed to create category: $e',
      ));
    }
  }

  // Delete category
  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final result = await _categoryService.deleteCategory(event.id);

      if (result.isSuccess) {
        emit(state.copyWith(
          categories: state.categories.where((c) => c.id != event.id).toList(),
          successMessage: 'Category deleted',
          selectedCategoryId: state.selectedCategoryId == event.id
              ? null
              : state.selectedCategoryId,
        ));
      } else {
        emit(state.copyWith(errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete category: $e'));
    }
  }

  // Select category
  void _onSelectCategory(SelectCategory event, Emitter<CategoryState> emit) {
    emit(state.copyWith(selectedCategoryId: event.id));
  }
}

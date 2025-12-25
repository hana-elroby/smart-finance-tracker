// Category State - حالات الفئات
// States for category management

import 'package:equatable/equatable.dart';
import '../../../../core/models/category_model.dart';

enum CategoryStatus {
  initial,
  loading,
  loaded,
  creating,
  error,
}

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String? errorMessage;
  final String? successMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.selectedCategoryId,
    this.errorMessage,
    this.successMessage,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    String? errorMessage,
    String? successMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  // Helper getters
  bool get isLoading => status == CategoryStatus.loading;
  bool get isCreating => status == CategoryStatus.creating;
  bool get hasCategories => categories.isNotEmpty;

  CategoryModel? get selectedCategory {
    if (selectedCategoryId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == selectedCategoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        selectedCategoryId,
        errorMessage,
        successMessage,
      ];
}

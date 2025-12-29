// Category API Service - خدمة الفئات
// Handles all category API calls

import 'api_service.dart';
import '../models/category_model.dart';

class CategoryApiService {
  static final CategoryApiService instance = CategoryApiService._internal();
  CategoryApiService._internal();
  factory CategoryApiService() => instance;

  final ApiService _api = ApiService();

  // Create category
  Future<CategoryApiResult> createCategory({
    required String name,
    String? color,
  }) async {
    final response = await _api.post('/category', body: {
      'name': name,
      'color': color ?? '#FF5733',
    });

    if (response.isSuccess) {
      final data = response.getData<Map<String, dynamic>>('data');
      if (data != null) {
        return CategoryApiResult.success(
          category: CategoryModel.fromMap(data),
          message: response.message,
        );
      }
    }

    return CategoryApiResult.failure(message: response.message ?? 'Failed to create category');
  }

  // Get all categories
  Future<CategoryListResult> getCategories({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _api.get('/category', queryParams: queryParams);

    if (response.isSuccess) {
      final dataList = response.getData<List>('data') ?? [];
      final count = response.getData<int>('count') ?? 0;

      final categories = dataList
          .map((item) => CategoryModel.fromMap(item as Map<String, dynamic>))
          .toList();

      return CategoryListResult.success(
        categories: categories,
        totalCount: count,
      );
    }

    return CategoryListResult.failure(message: response.message ?? 'Failed to get categories');
  }

  // Delete category
  Future<CategoryApiResult> deleteCategory(String id) async {
    final response = await _api.delete('/category/$id');

    if (response.isSuccess) {
      return CategoryApiResult.success(message: 'Category deleted');
    }

    return CategoryApiResult.failure(message: response.message ?? 'Failed to delete category');
  }

  // Get category by ID
  Future<CategoryApiResult> getCategory(String id) async {
    final response = await _api.get('/category/$id');

    if (response.isSuccess) {
      final data = response.getData<Map<String, dynamic>>('data') ?? response.data;
      if (data != null) {
        return CategoryApiResult.success(category: CategoryModel.fromMap(data));
      }
    }

    return CategoryApiResult.failure(message: response.message ?? 'Category not found');
  }

  // Get category with items
  Future<CategoryWithItemsResult> getCategoryWithItems(String id) async {
    final response = await _api.get('/category/$id/items');

    if (response.isSuccess) {
      final categoryData = response.getData<Map<String, dynamic>>('category') ?? response.data;
      final itemsData = response.getData<List>('items') ?? [];

      if (categoryData != null) {
        return CategoryWithItemsResult.success(
          category: CategoryModel.fromMap(categoryData),
          itemIds: itemsData.map((item) => (item['_id'] ?? item) as String).toList(),
        );
      }
    }

    return CategoryWithItemsResult.failure(message: response.message ?? 'Failed to get category');
  }

  // Update category
  Future<CategoryApiResult> updateCategory({
    required String id,
    String? name,
    String? color,
    String? icon,
    double? budget,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (color != null) body['color'] = color;
    if (icon != null) body['icon'] = icon;
    if (budget != null) body['budget'] = budget;

    final response = await _api.put('/category/$id', body: body);

    if (response.isSuccess) {
      final data = response.getData<Map<String, dynamic>>('data') ?? response.data;
      if (data != null) {
        return CategoryApiResult.success(
          category: CategoryModel.fromMap(data),
          message: 'Category updated',
        );
      }
    }

    return CategoryApiResult.failure(message: response.message ?? 'Failed to update category');
  }

  // Add items to category
  Future<CategoryApiResult> addItemsToCategory({
    required String categoryId,
    required List<String> itemIds,
  }) async {
    final response = await _api.post('/category/$categoryId/items', body: {
      'itemIds': itemIds,
    });

    if (response.isSuccess) {
      return CategoryApiResult.success(message: 'Items added to category');
    }

    return CategoryApiResult.failure(message: response.message ?? 'Failed to add items');
  }

  // Remove items from category
  Future<CategoryApiResult> removeItemsFromCategory({
    required String categoryId,
    required List<String> itemIds,
  }) async {
    final response = await _api.delete('/category/$categoryId/items', body: {
      'itemIds': itemIds,
    });

    if (response.isSuccess) {
      return CategoryApiResult.success(message: 'Items removed from category');
    }

    return CategoryApiResult.failure(message: response.message ?? 'Failed to remove items');
  }
}

// Category API Result
class CategoryApiResult {
  final bool isSuccess;
  final CategoryModel? category;
  final String? message;

  CategoryApiResult._({
    required this.isSuccess,
    this.category,
    this.message,
  });

  factory CategoryApiResult.success({
    CategoryModel? category,
    String? message,
  }) {
    return CategoryApiResult._(
      isSuccess: true,
      category: category,
      message: message,
    );
  }

  factory CategoryApiResult.failure({required String message}) {
    return CategoryApiResult._(
      isSuccess: false,
      message: message,
    );
  }
}

// Category List Result
class CategoryListResult {
  final bool isSuccess;
  final List<CategoryModel> categories;
  final int totalCount;
  final String? message;

  CategoryListResult._({
    required this.isSuccess,
    this.categories = const [],
    this.totalCount = 0,
    this.message,
  });

  factory CategoryListResult.success({
    required List<CategoryModel> categories,
    required int totalCount,
  }) {
    return CategoryListResult._(
      isSuccess: true,
      categories: categories,
      totalCount: totalCount,
    );
  }

  factory CategoryListResult.failure({required String message}) {
    return CategoryListResult._(
      isSuccess: false,
      message: message,
    );
  }
}

// Category with Items Result
class CategoryWithItemsResult {
  final bool isSuccess;
  final CategoryModel? category;
  final List<String> itemIds;
  final String? message;

  CategoryWithItemsResult._({
    required this.isSuccess,
    this.category,
    this.itemIds = const [],
    this.message,
  });

  factory CategoryWithItemsResult.success({
    required CategoryModel category,
    required List<String> itemIds,
  }) {
    return CategoryWithItemsResult._(
      isSuccess: true,
      category: category,
      itemIds: itemIds,
    );
  }

  factory CategoryWithItemsResult.failure({required String message}) {
    return CategoryWithItemsResult._(isSuccess: false, message: message);
  }
}

// Item API Service - خدمة العناصر
// Handles all item-related API calls

import 'api_service.dart';
import '../models/item_model.dart';

class ItemApiService {
  static final ItemApiService instance = ItemApiService._internal();
  ItemApiService._internal();
  factory ItemApiService() => instance;

  final ApiService _api = ApiService();

  // Create Item
  Future<ItemApiResult> createItem({
    required String name,
    double? price,
    String? categoryId,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (price != null) body['price'] = price;
    if (categoryId != null) body['categoryId'] = categoryId;

    final response = await _api.post('/items', body: body);

    if (response.isSuccess) {
      final itemData = response.getData<Map<String, dynamic>>('item') ?? response.data;
      if (itemData != null) {
        return ItemApiResult.success(
          item: ItemModel.fromMap(itemData),
          message: 'Item created',
        );
      }
    }

    return ItemApiResult.failure(message: response.message ?? 'Failed to create item');
  }

  // Get My Items
  Future<ItemListResult> getItems() async {
    final response = await _api.get('/items');

    if (response.isSuccess) {
      final itemsData = response.getData<List>('items') ?? response.data ?? [];
      final items = itemsData
          .map((item) => ItemModel.fromMap(item as Map<String, dynamic>))
          .toList();

      return ItemListResult.success(items: items);
    }

    return ItemListResult.failure(message: response.message ?? 'Failed to load items');
  }

  // Get Item by ID
  Future<ItemApiResult> getItem(String id) async {
    final response = await _api.get('/items/$id');

    if (response.isSuccess) {
      final itemData = response.getData<Map<String, dynamic>>('item') ?? response.data;
      if (itemData != null) {
        return ItemApiResult.success(item: ItemModel.fromMap(itemData));
      }
    }

    return ItemApiResult.failure(message: response.message ?? 'Item not found');
  }

  // Update Item
  Future<ItemApiResult> updateItem({
    required String id,
    String? name,
    double? price,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (price != null) body['price'] = price;

    final response = await _api.put('/items/$id', body: body);

    if (response.isSuccess) {
      final itemData = response.getData<Map<String, dynamic>>('item') ?? response.data;
      if (itemData != null) {
        return ItemApiResult.success(
          item: ItemModel.fromMap(itemData),
          message: 'Item updated',
        );
      }
    }

    return ItemApiResult.failure(message: response.message ?? 'Failed to update item');
  }

  // Delete Item
  Future<ItemApiResult> deleteItem(String id) async {
    final response = await _api.delete('/items/$id');

    if (response.isSuccess) {
      return ItemApiResult.success(message: 'Item deleted');
    }

    return ItemApiResult.failure(message: response.message ?? 'Failed to delete item');
  }

  // Add Item to Category
  Future<ItemApiResult> addToCategory({
    required String itemId,
    required String categoryId,
  }) async {
    final response = await _api.post('/items/add-to-category', body: {
      'itemId': itemId,
      'categoryId': categoryId,
    });

    if (response.isSuccess) {
      return ItemApiResult.success(message: 'Item added to category');
    }

    return ItemApiResult.failure(message: response.message ?? 'Failed to add item to category');
  }

  // Remove Item from Category
  Future<ItemApiResult> removeFromCategory({
    required String itemId,
    required String categoryId,
  }) async {
    final response = await _api.post('/items/remove-from-category', body: {
      'itemId': itemId,
      'categoryId': categoryId,
    });

    if (response.isSuccess) {
      return ItemApiResult.success(message: 'Item removed from category');
    }

    return ItemApiResult.failure(message: response.message ?? 'Failed to remove item from category');
  }
}

// Item API Result
class ItemApiResult {
  final bool isSuccess;
  final ItemModel? item;
  final String? message;

  ItemApiResult._({
    required this.isSuccess,
    this.item,
    this.message,
  });

  factory ItemApiResult.success({ItemModel? item, String? message}) {
    return ItemApiResult._(isSuccess: true, item: item, message: message);
  }

  factory ItemApiResult.failure({required String message}) {
    return ItemApiResult._(isSuccess: false, message: message);
  }
}

// Item List Result
class ItemListResult {
  final bool isSuccess;
  final List<ItemModel> items;
  final String? message;

  ItemListResult._({
    required this.isSuccess,
    this.items = const [],
    this.message,
  });

  factory ItemListResult.success({required List<ItemModel> items}) {
    return ItemListResult._(isSuccess: true, items: items);
  }

  factory ItemListResult.failure({required String message}) {
    return ItemListResult._(isSuccess: false, message: message);
  }
}

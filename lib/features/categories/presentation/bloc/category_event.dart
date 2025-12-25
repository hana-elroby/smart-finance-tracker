// Category Events - أحداث الفئات
// Events for category management

import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

// Load all categories
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

// Create new category
class CreateCategory extends CategoryEvent {
  final String name;

  const CreateCategory(this.name);

  @override
  List<Object?> get props => [name];
}

// Delete category
class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

// Select category
class SelectCategory extends CategoryEvent {
  final String? id;

  const SelectCategory(this.id);

  @override
  List<Object?> get props => [id];
}

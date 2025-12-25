// Expense Events - أحداث المصاريف
// Events for expense management

import 'package:equatable/equatable.dart';
import '../../../../core/models/expense_model.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

// Load all expenses
class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

// Add new expense
class AddExpense extends ExpenseEvent {
  final String title;
  final double amount;
  final String? category;
  final DateTime date;
  final String? description;

  const AddExpense({
    required this.title,
    required this.amount,
    this.category,
    required this.date,
    this.description,
  });

  @override
  List<Object?> get props => [title, amount, category, date, description];
}

// Update existing expense
class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

// Delete expense
class DeleteExpense extends ExpenseEvent {
  final int id;
  final String? firestoreId;

  const DeleteExpense({required this.id, this.firestoreId});

  @override
  List<Object?> get props => [id, firestoreId];
}

// Filter by category
class FilterByCategory extends ExpenseEvent {
  final String? category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

// Filter by date range
class FilterByDateRange extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// Clear all filters
class ClearFilter extends ExpenseEvent {
  const ClearFilter();
}

// Sync expenses with server
class SyncExpenses extends ExpenseEvent {
  const SyncExpenses();
}

// Search expenses
class SearchExpenses extends ExpenseEvent {
  final String query;

  const SearchExpenses(this.query);

  @override
  List<Object?> get props => [query];
}

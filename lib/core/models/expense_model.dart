/// @deprecated Use ExpenseModel from data/models/expense_model.dart
///
/// This duplicate model has different field types (int? id vs String id)
/// and should be migrated to the proper data layer model.
///
/// Migration:
/// - Import 'data/models/expense_model.dart' instead
/// - Update field access patterns accordingly
@Deprecated('Use ExpenseModel from data/models/expense_model.dart instead')
class Expense {
  int? id;
  String title;
  double amount;
  String? category;
  String date;
  String? description;
  int isSynced;
  String createdAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    this.category,
    required this.date,
    this.description,
    this.isSynced = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "category": category,
      "date": date,
      "description": description,
      "isSynced": isSynced,
      "createdAt": createdAt,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map["id"],
      title: map["title"],
      amount: map["amount"],
      category: map["category"],
      date: map["date"],
      description: map["description"],
      isSynced: map["isSynced"] ?? 0,
      createdAt: map["createdAt"],
    );
  }
}



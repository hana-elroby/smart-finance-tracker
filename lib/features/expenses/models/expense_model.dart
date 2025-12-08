// Model للمصروف
class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  // نسخة من الـ Model
  ExpenseModel copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

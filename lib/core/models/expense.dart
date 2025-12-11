class Expense {
  final String id;
  final double amount;
  final String category; // 'Shopping', 'Bills', 'Health', etc.
  final String title;
  final DateTime date;
  final String? notes;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.title,
    required this.date,
    this.notes,
  });

  // Convert to Map for Firebase/Storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'title': title,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }

  // Copy with method for updates
  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? title,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      title: title ?? this.title,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}

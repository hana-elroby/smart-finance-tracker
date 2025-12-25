// Firestore Service - خدمة قاعدة البيانات السحابية
// Handles all Cloud Firestore operations for expenses

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();
  factory FirestoreService() => instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection reference for user's expenses
  CollectionReference<Map<String, dynamic>> get _expensesCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('expenses');
  }

  // Add expense to Firestore
  Future<String?> addExpense(Expense expense) async {
    try {
      if (_userId == null) return null;

      final docRef = await _expensesCollection.add({
        ...expense.toMap(),
        'userId': _userId,
        'serverTimestamp': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('❌ Error adding expense to Firestore: $e');
      return null;
    }
  }

  // Update expense in Firestore
  Future<bool> updateExpense(String docId, Expense expense) async {
    try {
      if (_userId == null) return false;

      await _expensesCollection.doc(docId).update({
        ...expense.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('❌ Error updating expense: $e');
      return false;
    }
  }

  // Delete expense from Firestore
  Future<bool> deleteExpense(String docId) async {
    try {
      if (_userId == null) return false;

      await _expensesCollection.doc(docId).delete();
      return true;
    } catch (e) {
      print('❌ Error deleting expense: $e');
      return false;
    }
  }

  // Get all expenses from Firestore
  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      if (_userId == null) return [];

      final snapshot = await _expensesCollection
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firestoreId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting expenses: $e');
      return [];
    }
  }

  // Get expenses stream for real-time updates
  Stream<List<Expense>> getExpensesStream() {
    if (_userId == null) return Stream.value([]);

    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firestoreId'] = doc.id;
        return Expense.fromMap(data);
      }).toList();
    });
  }

  // Sync local expense to Firestore
  Future<bool> syncExpense(Expense expense) async {
    try {
      final docId = await addExpense(expense);
      return docId != null;
    } catch (e) {
      print('❌ Sync failed: $e');
      return false;
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      if (_userId == null) return [];

      final snapshot = await _expensesCollection
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firestoreId'] = doc.id;
        return Expense.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error getting expenses by category: $e');
      return [];
    }
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_userId == null) return [];

      final snapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['firestoreId'] = doc.id;
        return Expense.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error getting expenses by date range: $e');
      return [];
    }
  }

  // Get total expenses amount
  Future<double> getTotalExpenses() async {
    try {
      final expenses = await getExpenses();
      return expenses.fold<double>(
        0,
        (sum, expense) => sum + (expense['amount'] as num).toDouble(),
      );
    } catch (e) {
      return 0;
    }
  }

  // Get expenses grouped by category
  Future<Map<String, double>> getExpensesByCategories() async {
    try {
      final expenses = await getExpenses();
      final Map<String, double> categoryTotals = {};

      for (final expense in expenses) {
        final category = expense['category'] as String? ?? 'Other';
        final amount = (expense['amount'] as num).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      return {};
    }
  }
}

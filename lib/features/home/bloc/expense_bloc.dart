import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(const ExpenseLoaded([])) {
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<LoadExpenses>(_onLoadExpenses);
  }

  void _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedExpenses = List<Expense>.from(currentState.expenses)
        ..add(event.expense);
      emit(ExpenseLoaded(updatedExpenses));

      // TODO: Save to Firebase
      // await _firebaseRepository.addExpense(event.expense);
    }
  }

  void _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedExpenses = currentState.expenses
          .where((expense) => expense.id != event.expenseId)
          .toList();
      emit(ExpenseLoaded(updatedExpenses));

      // TODO: Delete from Firebase
      // await _firebaseRepository.deleteExpense(event.expenseId);
    }
  }

  void _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final updatedExpenses = currentState.expenses.map((expense) {
        return expense.id == event.expense.id ? event.expense : expense;
      }).toList();
      emit(ExpenseLoaded(updatedExpenses));

      // TODO: Update in Firebase
      // await _firebaseRepository.updateExpense(event.expense);
    }
  }

  void _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      // TODO: Load from Firebase
      // final expenses = await _firebaseRepository.getExpenses();
      // emit(ExpenseLoaded(expenses));

      // For now, start with empty list
      emit(const ExpenseLoaded([]));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/reminder.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';
import '../../../services/notification_service.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final NotificationService _notificationService = NotificationService();
  
  ReminderBloc() : super(const ReminderInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<UpdateReminder>(_onUpdateReminder);
    on<DeleteReminder>(_onDeleteReminder);
    on<ToggleReminder>(_onToggleReminder);
    on<DeleteMultipleReminders>(_onDeleteMultiple);
    
    // Load initial sample data
    add(const LoadReminders());
  }

  void _onLoadReminders(LoadReminders event, Emitter<ReminderState> emit) {
    final now = DateTime.now();
    final sampleReminders = [
      Reminder(
        id: '1',
        title: 'Electricity Bill',
        amount: 350.0,
        date: DateTime(now.year, now.month, 25, 10, 0),
        repeat: 'Monthly',
        enabled: true,
        icon: Icons.bolt_rounded,
      ),
      Reminder(
        id: '2',
        title: 'Rent Payment',
        amount: 5000.0,
        date: DateTime(now.year, now.month + 1, 1, 9, 0),
        repeat: 'Monthly',
        enabled: true,
        icon: Icons.home_rounded,
      ),
      Reminder(
        id: '3',
        title: 'Netflix Subscription',
        amount: 199.0,
        date: DateTime(now.year, now.month, now.day + 5, 12, 0),
        repeat: 'Monthly',
        enabled: true,
        icon: Icons.tv_rounded,
      ),
      Reminder(
        id: '4',
        title: 'Grocery Shopping',
        amount: null,
        date: DateTime(now.year, now.month, now.day + 1, 17, 0),
        repeat: 'Once',
        enabled: false,
        icon: Icons.shopping_cart_rounded,
      ),
    ];
    
    // Schedule notifications for enabled reminders
    for (final reminder in sampleReminders) {
      if (reminder.enabled) {
        _notificationService.scheduleReminder(reminder);
      }
    }
    
    emit(ReminderLoaded(sampleReminders));
  }

  void _onAddReminder(AddReminder event, Emitter<ReminderState> emit) {
    if (state is ReminderLoaded) {
      final currentState = state as ReminderLoaded;
      final updatedReminders = [event.reminder, ...currentState.reminders];
      
      // Schedule notification
      if (event.reminder.enabled) {
        _notificationService.scheduleReminder(event.reminder);
      }
      
      emit(ReminderLoaded(updatedReminders));
    }
  }

  void _onUpdateReminder(UpdateReminder event, Emitter<ReminderState> emit) {
    if (state is ReminderLoaded) {
      final currentState = state as ReminderLoaded;
      final updatedReminders = currentState.reminders.map((r) {
        return r.id == event.reminder.id ? event.reminder : r;
      }).toList();
      
      // Cancel old and schedule new notification
      _notificationService.cancelReminder(event.reminder.id);
      if (event.reminder.enabled) {
        _notificationService.scheduleReminder(event.reminder);
      }
      
      emit(ReminderLoaded(updatedReminders));
    }
  }

  void _onDeleteReminder(DeleteReminder event, Emitter<ReminderState> emit) {
    if (state is ReminderLoaded) {
      final currentState = state as ReminderLoaded;
      final updatedReminders = currentState.reminders
          .where((r) => r.id != event.id)
          .toList();
      
      // Cancel notification
      _notificationService.cancelReminder(event.id);
      
      emit(ReminderLoaded(updatedReminders));
    }
  }

  void _onToggleReminder(ToggleReminder event, Emitter<ReminderState> emit) {
    debugPrint('=== TOGGLE REMINDER: ${event.id} ===');
    if (state is ReminderLoaded) {
      final currentState = state as ReminderLoaded;
      final updatedReminders = currentState.reminders.map((r) {
        if (r.id == event.id) {
          final updated = r.copyWith(enabled: !r.enabled);
          debugPrint('=== Toggled ${r.title}: ${r.enabled} -> ${updated.enabled} ===');
          // Schedule or cancel notification based on new state
          if (updated.enabled) {
            _notificationService.scheduleReminder(updated);
          } else {
            _notificationService.cancelReminder(updated.id);
          }
          return updated;
        }
        return r;
      }).toList();
      // Create new list to ensure state change is detected
      final newState = ReminderLoaded(List<Reminder>.from(updatedReminders));
      debugPrint('=== New activeCount: ${newState.activeCount} ===');
      emit(newState);
    }
  }

  void _onDeleteMultiple(DeleteMultipleReminders event, Emitter<ReminderState> emit) {
    if (state is ReminderLoaded) {
      final currentState = state as ReminderLoaded;
      
      // Cancel notifications for deleted reminders
      for (final id in event.ids) {
        _notificationService.cancelReminder(id);
      }
      
      final updatedReminders = currentState.reminders
          .where((r) => !event.ids.contains(r.id))
          .toList();
      emit(ReminderLoaded(updatedReminders));
    }
  }
}

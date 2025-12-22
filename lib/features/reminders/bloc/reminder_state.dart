import 'package:equatable/equatable.dart';
import '../models/reminder.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;

  const ReminderLoaded(this.reminders);

  int get activeCount => reminders.where((r) => r.enabled).length;
  int get totalCount => reminders.length;

  @override
  List<Object?> get props => [reminders];
}

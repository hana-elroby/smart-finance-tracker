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
  final int _timestamp; // Force rebuild on every emit

  ReminderLoaded(this.reminders) : _timestamp = DateTime.now().millisecondsSinceEpoch;

  int get activeCount => reminders.where((r) => r.enabled).length;
  int get totalCount => reminders.length;

  @override
  List<Object?> get props => [_timestamp, activeCount, totalCount];
}

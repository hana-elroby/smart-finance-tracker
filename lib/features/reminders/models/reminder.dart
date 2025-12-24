import 'package:flutter/material.dart';

enum ReminderSound {
  defaultSound('Default', Icons.notifications_active),
  alarm1('Alarm', Icons.alarm),
  alarm2('Alert', Icons.warning_amber_rounded),
  gentle('Gentle', Icons.music_note),
  silent('Silent', Icons.notifications_off);

  final String label;
  final IconData icon;
  const ReminderSound(this.label, this.icon);
}

class Reminder {
  final String id;
  final String title;
  final double? amount;
  final DateTime date;
  final String repeat;
  final bool enabled;
  final IconData icon;
  final ReminderSound sound;

  const Reminder({
    required this.id,
    required this.title,
    this.amount,
    required this.date,
    required this.repeat,
    required this.enabled,
    required this.icon,
    this.sound = ReminderSound.defaultSound,
  });

  Reminder copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? repeat,
    bool? enabled,
    IconData? icon,
    ReminderSound? sound,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      repeat: repeat ?? this.repeat,
      enabled: enabled ?? this.enabled,
      icon: icon ?? this.icon,
      sound: sound ?? this.sound,
    );
  }
}

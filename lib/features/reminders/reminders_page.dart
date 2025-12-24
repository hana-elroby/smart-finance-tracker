import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/reminder_bloc.dart';
import 'bloc/reminder_event.dart';
import 'bloc/reminder_state.dart';
import 'models/reminder.dart';

/// Reminders Page - Financial Reminders & Notes
class RemindersPage extends StatefulWidget {
  final ReminderBloc? reminderBloc;
  
  const RemindersPage({super.key, this.reminderBloc});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // If bloc is passed, use BlocProvider.value to share it
    // Otherwise, try to get from context or create new one
    if (widget.reminderBloc != null) {
      return BlocProvider.value(
        value: widget.reminderBloc!,
        child: Builder(
          builder: (blocContext) => _buildContent(blocContext),
        ),
      );
    }
    
    // Try to get existing bloc from context
    ReminderBloc? existingBloc;
    try {
      existingBloc = context.read<ReminderBloc>();
    } catch (_) {
      existingBloc = null;
    }
    
    if (existingBloc != null) {
      return _buildContent(context);
    }
    
    // Create new bloc if none exists
    return BlocProvider(
      create: (context) => ReminderBloc(),
      child: Builder(
        builder: (blocContext) => _buildContent(blocContext),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocListener<ReminderBloc, ReminderState>(
      listener: (context, state) {
        // Force rebuild when state changes
        if (mounted) setState(() {});
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedIds.clear();
            });
          },
        ),
        title: Text(
          '${_selectedIds.length} selected',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state is! ReminderLoaded) return const SizedBox();
              return TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIds.length == state.reminders.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds = state.reminders.map((r) => r.id).toSet();
                    }
                  });
                },
                child: Text(
                  _selectedIds.length == state.reminders.length ? 'Deselect all' : 'Select all',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0D5DB8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteSelected,
            ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Reminders',
        style: GoogleFonts.inter(
          color: const Color(0xFF0D5DB8),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            if (state is ReminderLoaded && state.reminders.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.checklist_rounded, color: Color(0xFF64748B)),
                onPressed: () => setState(() => _isSelectionMode = true),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ReminderBloc, ReminderState>(
      buildWhen: (previous, current) => true, // Always rebuild
      builder: (context, state) {
        if (state is! ReminderLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final reminders = state.reminders;
        final activeCount = reminders.where((r) => r.enabled).length;
        final totalCount = reminders.length;

        if (reminders.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  _buildStatChip(
                    icon: Icons.notifications_active_rounded,
                    label: '$activeCount Active',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    icon: Icons.list_rounded,
                    label: '$totalCount Total',
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),

            // Reminders list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: reminders.length,
                itemBuilder: (listContext, index) => _buildReminderCard(listContext, reminders[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext blocContext, Reminder reminder) {
    final isSelected = _selectedIds.contains(reminder.id);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _isSelectionMode = true;
          _selectedIds.add(reminder.id);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(reminder.id);
              if (_selectedIds.isEmpty) _isSelectionMode = false;
            } else {
              _selectedIds.add(reminder.id);
            }
          });
        } else {
          _showEditReminderDialog(reminder);
        }
      },
      child: Dismissible(
        key: Key('reminder_${reminder.id}_${DateTime.now().millisecondsSinceEpoch}'),
        direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          final confirmed = await _confirmDelete(reminder.title);
          if (confirmed == true) {
            blocContext.read<ReminderBloc>().add(DeleteReminder(reminder.id));
          }
          return false; // Don't let Dismissible remove the widget, let BLoC handle it
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D5DB8).withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: const Color(0xFF0D5DB8), width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: reminder.enabled
                      ? const Color(0xFF0D5DB8).withValues(alpha: 0.1)
                      : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  reminder.icon,
                  color: reminder.enabled ? const Color(0xFF0D5DB8) : const Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: reminder.enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (reminder.amount != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${reminder.amount!.toStringAsFixed(0)} EGP',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: reminder.enabled ? const Color(0xFF0D5DB8) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: reminder.enabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(reminder.date),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: reminder.enabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        if (reminder.repeat != 'Once') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: reminder.enabled
                                  ? const Color(0xFF0D5DB8).withValues(alpha: 0.1)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              reminder.repeat,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: reminder.enabled ? const Color(0xFF0D5DB8) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Toggle or Checkbox
              if (_isSelectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedIds.add(reminder.id);
                      } else {
                        _selectedIds.remove(reminder.id);
                        if (_selectedIds.isEmpty) _isSelectionMode = false;
                      }
                    });
                  },
                  activeColor: const Color(0xFF0D5DB8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                )
              else
                Switch(
                  value: reminder.enabled,
                  onChanged: (value) {
                    blocContext.read<ReminderBloc>().add(ToggleReminder(reminder.id));
                  },
                  activeColor: const Color(0xFF0D5DB8),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(now.year, now.month, now.day);
    final tomorrowOnly = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    String dayStr;
    if (dateOnly == todayOnly) {
      dayStr = 'Today';
    } else if (dateOnly == tomorrowOnly) {
      dayStr = 'Tomorrow';
    } else {
      dayStr = '${date.day}/${date.month}';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$dayStr, $hour:$minute';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF0D5DB8).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 50,
              color: Color(0xFF0D5DB8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reminders Yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first reminder',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    if (_isSelectionMode) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: _showAddReminderDialog,
              backgroundColor: const Color(0xFF0D5DB8),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSelected() {
    // Capture bloc reference BEFORE showing dialog
    final reminderBloc = widget.reminderBloc ?? context.read<ReminderBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Reminders?'),
        content: Text('Delete ${_selectedIds.length} selected reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              reminderBloc.add(DeleteMultipleReminders(_selectedIds.toList()));
              setState(() {
                _selectedIds.clear();
                _isSelectionMode = false;
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  // ==================== ADD/EDIT DIALOGS ====================
  void _showAddReminderDialog() {
    // Capture bloc reference BEFORE showing dialog to avoid context issues
    final reminderBloc = widget.reminderBloc ?? context.read<ReminderBloc>();
    
    String title = '';
    double? amount;
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String repeat = 'Once';
    IconData selectedIcon = Icons.notifications_rounded;
    ReminderSound selectedSound = ReminderSound.defaultSound;

    final icons = [
      Icons.notifications_rounded,
      Icons.bolt_rounded,
      Icons.home_rounded,
      Icons.tv_rounded,
      Icons.shopping_cart_rounded,
      Icons.phone_android_rounded,
      Icons.wifi_rounded,
      Icons.water_drop_rounded,
      Icons.local_gas_station_rounded,
      Icons.credit_card_rounded,
      Icons.school_rounded,
      Icons.medical_services_rounded,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
                      ),
                      Text('New Reminder', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () {
                          if (title.isNotEmpty) {
                            final dateTime = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              selectedTime.hour, selectedTime.minute,
                            );
                            final newReminder = Reminder(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              amount: amount,
                              date: dateTime,
                              repeat: repeat,
                              enabled: true,
                              icon: selectedIcon,
                              sound: selectedSound,
                            );
                            reminderBloc.add(AddReminder(newReminder));
                            Navigator.pop(ctx);
                          }
                        },
                        child: Text('Save', style: GoogleFonts.inter(color: const Color(0xFF0D5DB8), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Icon', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: icons.map((icon) => GestureDetector(
                            onTap: () => setModalState(() => selectedIcon = icon),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selectedIcon == icon ? const Color(0xFF0D5DB8) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: selectedIcon == icon ? Colors.white : const Color(0xFF64748B), size: 22),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Title *',
                            hintText: 'e.g., Electricity Bill',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (value) => title = value,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Amount (optional)',
                            hintText: 'e.g., 350',
                            suffixText: 'EGP',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => amount = double.tryParse(value),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: ctx,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) setModalState(() => selectedDate = date);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 20, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final time = await showTimePicker(context: ctx, initialTime: selectedTime);
                                  if (time != null) setModalState(() => selectedTime = time);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 20, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: repeat,
                          decoration: InputDecoration(
                            labelText: 'Repeat',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: ['Once', 'Daily', 'Weekly', 'Monthly', 'Yearly']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) => setModalState(() => repeat = value!),
                        ),
                        const SizedBox(height: 16),
                        // Sound Selection
                        Text('Sound', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ReminderSound.values.map((sound) => GestureDetector(
                            onTap: () => setModalState(() => selectedSound = sound),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedSound == sound ? const Color(0xFF0D5DB8) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(sound.icon, size: 18, color: selectedSound == sound ? Colors.white : const Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    sound.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selectedSound == sound ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditReminderDialog(Reminder reminder) {
    // Capture bloc reference BEFORE showing dialog to avoid context issues
    final reminderBloc = widget.reminderBloc ?? context.read<ReminderBloc>();
    
    String title = reminder.title;
    double? amount = reminder.amount;
    DateTime selectedDate = reminder.date;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String repeat = reminder.repeat;
    IconData selectedIcon = reminder.icon;
    ReminderSound selectedSound = reminder.sound;

    final icons = [
      Icons.notifications_rounded,
      Icons.bolt_rounded,
      Icons.home_rounded,
      Icons.tv_rounded,
      Icons.shopping_cart_rounded,
      Icons.phone_android_rounded,
      Icons.wifi_rounded,
      Icons.water_drop_rounded,
      Icons.local_gas_station_rounded,
      Icons.credit_card_rounded,
      Icons.school_rounded,
      Icons.medical_services_rounded,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmDelete(reminder.title).then((confirmed) {
                            if (confirmed == true) {
                              reminderBloc.add(DeleteReminder(reminder.id));
                            }
                          });
                        },
                        child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
                      ),
                      Text('Edit Reminder', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () {
                          if (title.isNotEmpty) {
                            final dateTime = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              selectedTime.hour, selectedTime.minute,
                            );
                            final updatedReminder = Reminder(
                              id: reminder.id,
                              title: title,
                              amount: amount,
                              date: dateTime,
                              repeat: repeat,
                              enabled: reminder.enabled,
                              icon: selectedIcon,
                              sound: selectedSound,
                            );
                            reminderBloc.add(UpdateReminder(updatedReminder));
                            Navigator.pop(ctx);
                          }
                        },
                        child: Text('Save', style: GoogleFonts.inter(color: const Color(0xFF0D5DB8), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Icon', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: icons.map((icon) => GestureDetector(
                            onTap: () => setModalState(() => selectedIcon = icon),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selectedIcon == icon ? const Color(0xFF0D5DB8) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: selectedIcon == icon ? Colors.white : const Color(0xFF64748B), size: 22),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: title,
                          decoration: InputDecoration(
                            labelText: 'Title *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (value) => title = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: amount?.toStringAsFixed(0) ?? '',
                          decoration: InputDecoration(
                            labelText: 'Amount (optional)',
                            suffixText: 'EGP',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => amount = double.tryParse(value),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: ctx,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) setModalState(() => selectedDate = date);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 20, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final time = await showTimePicker(context: ctx, initialTime: selectedTime);
                                  if (time != null) setModalState(() => selectedTime = time);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 20, color: Color(0xFF64748B)),
                                      const SizedBox(width: 8),
                                      Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: repeat,
                          decoration: InputDecoration(
                            labelText: 'Repeat',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: ['Once', 'Daily', 'Weekly', 'Monthly', 'Yearly']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (value) => setModalState(() => repeat = value!),
                        ),
                        const SizedBox(height: 16),
                        // Sound Selection
                        Text('Sound', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ReminderSound.values.map((sound) => GestureDetector(
                            onTap: () => setModalState(() => selectedSound = sound),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedSound == sound ? const Color(0xFF0D5DB8) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(sound.icon, size: 18, color: selectedSound == sound ? Colors.white : const Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    sound.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: selectedSound == sound ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

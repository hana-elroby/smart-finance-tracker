import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import 'success_dialog.dart';

class VoiceRecordingDialog extends StatefulWidget {
  final String category;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onSuccess;

  const VoiceRecordingDialog({
    super.key,
    required this.category,
    required this.icon,
    required this.gradient,
    required this.onSuccess,
  });

  @override
  State<VoiceRecordingDialog> createState() => _VoiceRecordingDialogState();
}

class _VoiceRecordingDialogState extends State<VoiceRecordingDialog> {
  bool isRecording = false;
  bool hasRecorded = false; // Track if user has recorded something

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRecording ? 'Recording...' : 'Tap to Record',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Microphone Button (Changes color when recording)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isRecording = !isRecording;
                    // When user starts recording, enable Save button
                    if (isRecording) {
                      hasRecorded = true;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.gradient.colors.first.withValues(
                          alpha: isRecording ? 0.6 : 0.3,
                        ),
                        blurRadius: isRecording ? 30 : 15,
                        spreadRadius: isRecording ? 8 : 3,
                      ),
                    ],
                  ),
                  // Overlay to make it lighter/darker when recording
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isRecording)
                const Text(
                  '🎤 Listening...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 16),
              // Save Button (circular, appears after recording)
              GestureDetector(
                onTap: !hasRecorded
                    ? null
                    : () {
                        // TODO: In real implementation, parse voice input for amount
                        // For now, using dummy amount of 100 EGP
                        final expense = Expense(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          amount: 100.0, // TODO: Get from voice recognition
                          category: widget.category,
                          title: 'Voice Entry',
                          date: DateTime.now(),
                          notes: 'Added via voice recording',
                        );

                        context.read<ExpenseBloc>().add(AddExpense(expense));

                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const SuccessDialog(),
                          );
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: !hasRecorded
                        ? Colors.grey.shade300
                        : AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: !hasRecorded
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: !hasRecorded ? Colors.grey.shade500 : Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



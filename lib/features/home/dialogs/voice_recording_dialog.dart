import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                setState(() => isRecording = !isRecording);
                if (!isRecording) {
                  // Simulate recording completion
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pop(context);
                    widget.onSuccess();
                  });
                }
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
                      color: widget.gradient.colors.first.withOpacity(
                        isRecording ? 0.6 : 0.3,
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
                        ? Colors.white.withOpacity(0.2)
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
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            const SizedBox(height: 16),
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
    );
  }
}

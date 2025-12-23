import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Add expense bottom sheet with voice and scan options
class AddExpenseBottomSheet extends StatelessWidget {
  final VoidCallback onVoiceInput;
  final VoidCallback onScanReceipt;

  const AddExpenseBottomSheet({
    super.key,
    required this.onVoiceInput,
    required this.onScanReceipt,
  });

  /// Show the bottom sheet
  static void show({
    required BuildContext context,
    required VoidCallback onVoiceInput,
    required VoidCallback onScanReceipt,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => AddExpenseBottomSheet(
        onVoiceInput: onVoiceInput,
        onScanReceipt: onScanReceipt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(),
          const SizedBox(height: 24),
          // Title section
          _buildTitleSection(),
          const SizedBox(height: 32),
          // Action options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.mic_rounded,
                    title: 'Add by voice',
                    subtitle: 'Speak naturally and we\'ll handle the rest',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onVoiceInput();
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionRow(
                    icon: Icons.camera_alt_rounded,
                    title: 'Scan receipt',
                    subtitle: 'Automatically detect amount and details',
                    isPrimary: false,
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onScanReceipt();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Add Expense',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D5DB8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you\'d like to add an expense',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Action row widget for bottom sheet options
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFF6B7280).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF6B7280),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : const Color(0xFF0D5DB8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.8)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? Colors.white : const Color(0xFF6B7280),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// OCR options bottom sheet
class OCROptionsBottomSheet extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onPickFromGallery;

  const OCROptionsBottomSheet({
    super.key,
    required this.onTakePhoto,
    required this.onPickFromGallery,
  });

  /// Show the bottom sheet
  static void show({
    required BuildContext context,
    required VoidCallback onTakePhoto,
    required VoidCallback onPickFromGallery,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => OCROptionsBottomSheet(
        onTakePhoto: onTakePhoto,
        onPickFromGallery: onPickFromGallery,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Title section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Scan Receipt',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D5DB8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you\'d like to capture your receipt',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.camera_alt_rounded,
                    title: 'Take photo',
                    subtitle: 'Capture receipt with camera',
                    isPrimary: true,
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onTakePhoto();
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionRow(
                    icon: Icons.photo_library_rounded,
                    title: 'Choose from gallery',
                    subtitle: 'Select existing photo from gallery',
                    isPrimary: false,
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onPickFromGallery();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}



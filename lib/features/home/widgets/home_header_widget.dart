import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Home page header widget with user greeting and notification bell
class HomeHeader extends StatelessWidget {
  final String userName;
  final String motivationalQuote;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    required this.userName,
    this.motivationalQuote = 'Smart spending leads to bright savings!',
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting and quote
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $userName',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF003B73),
                ),
              ),
              const SizedBox(height: 8),
              _buildMotivationalRow(),
            ],
          ),
        ),
        // Notification bell
        _buildNotificationBell(context),
      ],
    );
  }

  Widget _buildMotivationalRow() {
    return Row(
      children: [
        _buildGradientCheckbox(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            motivationalQuote,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientCheckbox() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0814F9), Color(0xFFF907A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF0814F9), Color(0xFFF907A8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Icon(Icons.check, color: Colors.white, size: 12),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onNotificationTap != null) {
          onNotificationTap!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications - Coming soon!'),
              backgroundColor: Color(0xFF1687F0),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0814F9), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFE994), Color(0xFFFF8C00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              // Notification badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

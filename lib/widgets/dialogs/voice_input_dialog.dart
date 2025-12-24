import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Voice Input Dialog - Beautiful animated voice recording UI
class VoiceInputDialog extends StatefulWidget {
  const VoiceInputDialog({super.key});

  @override
  State<VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<VoiceInputDialog>
    with TickerProviderStateMixin {
  bool _isListening = false;
  String _recognizedText = '';
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
        // Simulate voice recognition after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isListening) {
            setState(() {
              _recognizedText = 'Coffee - 45 EGP';
              _isListening = false;
            });
            _pulseController.stop();
            _waveController.stop();
          }
        });
      } else {
        _pulseController.stop();
        _waveController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              'Voice Input',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D5DB8),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _isListening ? 'Listening...' : 'Tap the mic to start',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            // Animated Mic Button
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulse ring
                      if (_isListening)
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      // Middle ring
                      if (_isListening)
                        Transform.scale(
                          scale: _pulseAnimation.value * 0.85,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      // Main button
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isListening
                                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF3B82F6))
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Sound wave visualization
            if (_isListening)
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) {
                    return AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final delay = index * 0.1;
                        final value = ((_waveController.value + delay) % 1.0);
                        final height = 10 + (30 * (0.5 + 0.5 * 
                            (value < 0.5 ? value * 2 : (1 - value) * 2)));
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 4,
                          height: height,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),

            // Recognized text
            if (_recognizedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recognized',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _recognizedText = '';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF6B7280)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _recognizedText);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add Item',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (_recognizedText.isEmpty && !_isListening) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Say something like:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"Coffee 45 pounds"\n"Lunch 120 EGP"\n"Groceries 350"',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Show Voice Input Dialog
Future<String?> showVoiceInputDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const VoiceInputDialog(),
  );
}

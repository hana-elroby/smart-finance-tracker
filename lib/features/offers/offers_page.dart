import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Offers
            Text(
              'Featured Offers',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF003B73),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildOfferCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, int index) {
    final offers = [
      {
        'title': 'Smart Savings',
        'subtitle': 'Track & Save More',
        'discount': '25% OFF',
        'brand': 'FinTrack',
        'color': const Color(0xFF1687F0),
      },
      {
        'title': 'Budget Goals',
        'subtitle': 'Achieve targets',
        'discount': '30% OFF',
        'brand': 'MoneyWise',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Expense Tips',
        'subtitle': 'Smart habits',
        'discount': '20% OFF',
        'brand': 'SaveMore',
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Premium Plan',
        'subtitle': 'Advanced features',
        'discount': '40% OFF',
        'brand': 'ProTrack',
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Family Pack',
        'subtitle': 'Share & save',
        'discount': '35% OFF',
        'brand': 'FamSave',
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Student Deal',
        'subtitle': 'Special pricing',
        'discount': '50% OFF',
        'brand': 'EduSave',
        'color': const Color(0xFF6366F1),
      },
    ];

    final offer = offers[index % offers.length];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${offer['title']} - Coming soon!'),
            backgroundColor: offer['color'] as Color,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (offer['color'] as Color).withValues(alpha: 0.8),
              (offer['color'] as Color).withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (offer['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer['brand'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Discount
              Text(
                offer['discount'] as String,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Title
              Text(
                offer['title'] as String,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 2),
              
              // Subtitle
              Text(
                offer['subtitle'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

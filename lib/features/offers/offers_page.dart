import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Special Offers',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0D5DB8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Exclusive deals just for you',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Offers List
              ...List.generate(6, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOfferCard(context, index),
              )),
              
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, int index) {
    final offers = [
      {
        'title': 'Carrefour',
        'subtitle': 'Up to 50% off on groceries',
        'discount': '50%',
        'validUntil': 'Valid until Dec 25',
        'image': 'https://images.unsplash.com/photo-1604719312566-8908a0b3e7e0?w=400',
        'gradient': [const Color(0xFF1478E0), const Color(0xFF0D5DB8)],
        'tag': 'HOT DEAL',
      },
      {
        'title': 'Amazon',
        'subtitle': 'Electronics & gadgets sale',
        'discount': '30%',
        'validUntil': 'Valid until Dec 31',
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        'gradient': [const Color(0xFFFF9900), const Color(0xFFFF6600)],
        'tag': 'LIMITED',
      },
      {
        'title': 'Noon',
        'subtitle': 'Fashion & lifestyle deals',
        'discount': '40%',
        'validUntil': 'Valid until Jan 5',
        'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400',
        'gradient': [const Color(0xFFFFC61C), const Color(0xFFFFAA00)],
        'tag': 'TRENDING',
      },
      {
        'title': 'Talabat',
        'subtitle': 'Free delivery on orders +100 EGP',
        'discount': 'FREE',
        'validUntil': 'Valid this week',
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
        'gradient': [const Color(0xFFFF5A00), const Color(0xFFFF3D00)],
        'tag': 'DELIVERY',
      },
      {
        'title': 'IKEA',
        'subtitle': 'Home & furniture clearance',
        'discount': '35%',
        'validUntil': 'Valid until Jan 10',
        'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
        'gradient': [const Color(0xFF0058A3), const Color(0xFF003E6B)],
        'tag': 'CLEARANCE',
      },
      {
        'title': 'Vodafone',
        'subtitle': 'Extra GB on recharge',
        'discount': '2X',
        'validUntil': 'Valid until Dec 28',
        'image': 'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400',
        'gradient': [const Color(0xFFE60000), const Color(0xFFB30000)],
        'tag': 'BONUS',
      },
    ];

    final offer = offers[index % offers.length];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showOfferDetails(context, offer);
      },
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (offer['gradient'] as List<Color>)[0].withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: offer['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              
              // Background pattern
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left side - Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              offer['tag'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Title
                          Text(
                            offer['title'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Valid until
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  offer['validUntil'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Right side - Discount badge
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            offer['discount'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: (offer['gradient'] as List<Color>)[0],
                            ),
                          ),
                          if ((offer['discount'] as String).contains('%'))
                            Text(
                              'OFF',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: (offer['gradient'] as List<Color>)[0],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfferDetails(BuildContext context, Map<String, dynamic> offer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Offer header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: offer['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer['subtitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        offer['discount'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: (offer['gradient'] as List<Color>)[0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildDetailRow(Icons.access_time_rounded, 'Validity', offer['validUntil'] as String),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.local_offer_rounded, 'Discount', '${offer['discount']} on selected items'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.info_outline_rounded, 'Terms', 'Terms & conditions apply'),
                ],
              ),
            ),
            
            const Spacer(),
            
            // CTA Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${offer['title']}...'),
                        backgroundColor: (offer['gradient'] as List<Color>)[0],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (offer['gradient'] as List<Color>)[0],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get This Offer',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

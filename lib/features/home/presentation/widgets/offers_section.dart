import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data model for offer cards
class OfferData {
  final String title;
  final String subtitle;
  final String brand;
  final Color brandColor;
  final String imageUrl;
  final List<Color> fallbackGradient;

  const OfferData({
    required this.title,
    required this.subtitle,
    required this.brand,
    required this.brandColor,
    required this.imageUrl,
    required this.fallbackGradient,
  });
}

/// Offers section widget with horizontal scrolling cards
class OffersSection extends StatelessWidget {
  final VoidCallback? onShowMoreTap;
  final Function(int index)? onOfferTap;

  const OffersSection({super.key, this.onShowMoreTap, this.onOfferTap});

  static const List<OfferData> _defaultOffers = [
    OfferData(
      title: 'Smart Savings',
      subtitle: 'Track & Save More',
      brand: 'FinTrack',
      brandColor: Color(0xFF1478E0),
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=200&fit=crop&crop=center',
      fallbackGradient: [Color(0xFF1478E0), Color(0xFF0F446A)],
    ),
    OfferData(
      title: 'Budget Goals',
      subtitle: 'Achieve your targets',
      brand: 'MoneyWise',
      brandColor: Color(0xFF6B7280),
      imageUrl:
          'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=400&h=200&fit=crop&crop=center',
      fallbackGradient: [Color(0xFF6B7280), Color(0xFF4B5563)],
    ),
    OfferData(
      title: 'Expense Tips',
      subtitle: 'Smart spending habits',
      brand: 'SaveMore',
      brandColor: Color(0xFF10B981),
      imageUrl:
          'https://images.unsplash.com/photo-1604719312566-878836d2c3b9?w=400&h=200&fit=crop&crop=center',
      fallbackGradient: [Color(0xFF10B981), Color(0xFF059669)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _defaultOffers.length,
            itemBuilder: (context, index) {
              return _OfferCard(
                offer: _defaultOffers[index],
                index: index,
                isLast: index == _defaultOffers.length - 1,
                onTap: () => onOfferTap?.call(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Offers',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0D5DB8),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onShowMoreTap?.call();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Show More',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF374151),
                size: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual offer card widget
class _OfferCard extends StatelessWidget {
  final OfferData offer;
  final int index;
  final bool isLast;
  final VoidCallback? onTap;

  const _OfferCard({
    required this.offer,
    required this.index,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 300,
        margin: EdgeInsets.only(right: isLast ? 0 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildBackground(),
              _buildGradientOverlay(),
              _buildBrandLogo(),
              _buildTextOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: offer.fallbackGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Image.network(
        offer.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: offer.fallbackGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          offer.brand,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: offer.brandColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTextOverlay() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            offer.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            offer.subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}



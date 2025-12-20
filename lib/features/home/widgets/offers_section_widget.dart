import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Offer card data model
class OfferData {
  final String title;
  final String subtitle;
  final String brand;
  final Color brandColor;
  final String? imageUrl;
  final List<Color> fallbackGradient;

  const OfferData({
    required this.title,
    required this.subtitle,
    required this.brand,
    required this.brandColor,
    this.imageUrl,
    required this.fallbackGradient,
  });
}

/// Offers section widget with horizontal scrolling cards
class OffersSection extends StatelessWidget {
  final List<OfferData> offers;
  final VoidCallback? onShowMore;
  final void Function(OfferData offer)? onOfferTap;

  const OffersSection({
    super.key,
    this.offers = const [],
    this.onShowMore,
    this.onOfferTap,
  });

  /// Default offers data
  static const List<OfferData> defaultOffers = [
    OfferData(
      title: 'Smart Savings',
      subtitle: 'Track & Save More',
      brand: 'FinTrack',
      brandColor: Color(0xFF1687F0),
      imageUrl:
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=200&fit=crop&crop=center',
      fallbackGradient: [Color(0xFF1687F0), Color(0xFF0F446A)],
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
    final displayOffers = offers.isEmpty ? defaultOffers : offers;

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
            itemCount: displayOffers.length,
            itemBuilder: (context, index) {
              return _buildOfferCard(context, displayOffers[index], index);
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
            color: const Color(0xFF003B73),
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onShowMore?.call();
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

  Widget _buildOfferCard(BuildContext context, OfferData offer, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onOfferTap != null) {
          onOfferTap!(offer);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening offers...'),
              backgroundColor: Color(0xFF1D86D0),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        width: 300,
        margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
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
              // Background image/gradient
              _buildCardBackground(offer),
              // Gradient overlay
              _buildGradientOverlay(),
              // Brand logo
              _buildBrandLogo(offer),
              // Text content
              _buildTextContent(offer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBackground(OfferData offer) {
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
      child: offer.imageUrl != null
          ? Image.network(
              offer.imageUrl!,
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
            )
          : null,
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

  Widget _buildBrandLogo(OfferData offer) {
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

  Widget _buildTextContent(OfferData offer) {
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

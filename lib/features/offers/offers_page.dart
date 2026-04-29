import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/services/auth_api_service.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  List<bool> _saved = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final userId = AuthApiService.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) { 
        print('⚠️ [Offers] No userId — loading dummy');
        _loadDummy(); 
        return; 
      }
      print('🛍️ [Offers] Loading for userId: $userId');
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final token = await AuthApiService.instance.getToken();
      if (token != null) dio.options.headers['token'] = token;
      final response = await dio.get('/api/offers', queryParameters: {'userId': userId});
      print('🛍️ [Offers] Response: ${response.data['success']} products=${response.data['products']?.length}');
      if (response.data['success'] == true) {
        final rawProducts = List<Map<String, dynamic>>.from(response.data['products'] ?? []);

        // Helper: format price to EGP
        String formatPrice(dynamic val) {
          if (val == null) return '';
          final s = val.toString().trim();
          if (s.isEmpty || s == 'null') return '';
          if (s.toUpperCase().contains('EGP') || s.contains('ج.م')) return s;
          return s.replaceAll(RegExp(r'^\$'), 'EGP ').replaceAll('USD', 'EGP');
        }

        // Helper: fix URL to amazon.eg
        String fixUrl(dynamic val) {
          if (val == null || val.toString().isEmpty) return 'https://www.amazon.eg';
          return val.toString()
              .replaceAll('amazon.com', 'amazon.eg')
              .replaceAll('amazon.co.uk', 'amazon.eg');
        }

        // Dedup by name
        final seen = <String>{};
        final products = rawProducts
            .where((p) {
              final name = (p['title'] ?? p['name'] ?? '').toString().trim();
              if (name.isEmpty || seen.contains(name)) return false;
              seen.add(name);
              return true;
            })
            .map((p) {
          return {
            'name': p['title'] ?? p['name'] ?? 'Product',
            'price': formatPrice(p['price']),
            'oldPrice': formatPrice(p['original_price'] ?? p['oldPrice'] ?? p['originalPrice']),
            'discount': p['discount']?.toString() ?? '',
            'rating': p['rating']?.toString() ?? '4.0',
            'reviews': p['reviews']?.toString() ?? p['num_ratings']?.toString() ?? '0',
            'image': 'shopping_bag',
            'imageUrl': p['image']?.toString(),
            'url': fixUrl(p['url']),
          };
        }).toList();
        setState(() { _products = products; _saved = List.filled(products.length, false); _isLoading = false; });
        return;
      }
    } catch (e) {
      print('❌ [Offers] Error: $e');
    }
    _loadDummy();
  }

  /// Convert backend String or existing IconData to IconData safely
  IconData _resolveIcon(dynamic value) {
    if (value is IconData) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'watch': return Icons.watch;
        case 'headphones': return Icons.headphones;
        case 'backpack': return Icons.backpack;
        case 'tablet': return Icons.tablet;
        case 'keyboard': return Icons.keyboard;
        case 'battery': return Icons.battery_charging_full;
        case 'speaker': return Icons.speaker;
        case 'shoes': return Icons.directions_run;
        case 'phone': return Icons.phone_android;
        case 'laptop': return Icons.laptop;
        case 'camera': return Icons.camera_alt;
        case 'tv': return Icons.tv;
        case 'gaming': return Icons.sports_esports;
        case 'clothes': return Icons.checkroom;
        case 'food': return Icons.restaurant;
        case 'book': return Icons.book;
        default: return Icons.shopping_bag;
      }
    }
    return Icons.shopping_bag;
  }

  void _loadDummy() {    final dummy = [
      {'name': 'Amazfit Bip 5 Smart Watch', 'price': 'EGP 3,499', 'oldPrice': 'EGP 6,399', 'discount': '-35%', 'rating': '4.5', 'reviews': '2,489', 'image': Icons.watch, 'url': 'https://www.amazon.eg'},
      {'name': 'Apple AirPods Pro', 'price': 'EGP 6,799', 'oldPrice': 'EGP 8,499', 'discount': '-30%', 'rating': '4.7', 'reviews': '18,903', 'image': Icons.headphones, 'url': 'https://www.amazon.eg'},
      {'name': 'Samsonite Laptop Backpack', 'price': 'EGP 1,259', 'oldPrice': 'EGP 1,299', 'discount': '-30%', 'rating': '4.4', 'reviews': '1,203', 'image': Icons.backpack, 'url': 'https://www.amazon.eg'},
      {'name': 'Samsung Galaxy Tab A9', 'price': 'EGP 8,999', 'oldPrice': 'EGP 12,999', 'discount': '-31%', 'rating': '4.6', 'reviews': '5,120', 'image': Icons.tablet, 'url': 'https://www.amazon.eg'},
      {'name': 'Wireless Keyboard & Mouse', 'price': 'EGP 599', 'oldPrice': 'EGP 899', 'discount': '-33%', 'rating': '4.3', 'reviews': '3,400', 'image': Icons.keyboard, 'url': 'https://www.amazon.eg'},
      {'name': 'Portable Power Bank 20000mAh', 'price': 'EGP 449', 'oldPrice': 'EGP 699', 'discount': '-36%', 'rating': '4.5', 'reviews': '8,210', 'image': Icons.battery_charging_full, 'url': 'https://www.amazon.eg'},
      {'name': 'Bluetooth Speaker JBL', 'price': 'EGP 1,899', 'oldPrice': 'EGP 2,799', 'discount': '-32%', 'rating': '4.8', 'reviews': '12,500', 'image': Icons.speaker, 'url': 'https://www.amazon.eg'},
      {'name': 'Running Shoes Nike', 'price': 'EGP 2,199', 'oldPrice': 'EGP 3,499', 'discount': '-37%', 'rating': '4.6', 'reviews': '6,780', 'image': Icons.directions_run, 'url': 'https://www.amazon.eg'},
    ];
    setState(() { _products = dummy; _saved = List.filled(dummy.length, false); _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F4FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBanner(),
              _buildRecommendedSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offers',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Personalized offers from ',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  // Amazon logo text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'amazon',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF232F3E),
                        ),
                      ),
                      CustomPaint(
                        size: const Size(52, 6),
                        painter: _AmazonSmilePainter(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Bell icon - same as home page
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0814F9),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
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
                        child: const Icon(Icons.notifications, color: Colors.white, size: 22),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
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
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEBFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✦', style: TextStyle(fontSize: 16, color: Color(0xFF6C47FF))),
                      const SizedBox(width: 6),
                      Text(
                        'Offers just for you!',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We found these deals based on your\ninterests and spending habits.',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text('🎁', style: TextStyle(fontSize: 52)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Recommended for you',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.52,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(
                _products[index],
                index < _saved.length ? _saved[index] : false,
                () => setState(() { if (index < _saved.length) _saved[index] = !_saved[index]; }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> offer, bool saved, VoidCallback onSave) {
    // Safely get icon — backend may return String, dummy data returns IconData
    final IconData iconData = _resolveIcon(offer['image']);
    // Safely get image URL if available
    final String? imageUrl = offer['imageUrl'] as String?;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorBuilder: (_, __, ___) =>
                              Center(child: Icon(iconData, size: 56, color: Colors.grey.shade400)),
                        ),
                      )
                    : Center(child: Icon(iconData, size: 56, color: Colors.grey.shade400)),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                  child: Text(offer['discount'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onSave,
                  child: Icon(saved ? Icons.favorite : Icons.favorite_border, size: 20, color: saved ? Colors.red : Colors.grey),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer['name'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(offer['price'], style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0D5DB8))),
                Text(offer['oldPrice'], style: GoogleFonts.inter(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Color(0xFFFFB800)),
                    Text(' ${offer['rating']}(${offer['reviews']})', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse(offer['url'])),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF00B0D7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('View on Amazon', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('a', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87)),
                              CustomPaint(
                                size: const Size(10, 4),
                                painter: _AmazonSmilePainter(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFDEEAFF)),
              child: const Icon(Icons.lightbulb_outline, color: Color(0xFF0D5DB8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why you\'re seeing these offers?', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Based on your recent activity in Electronics and your purchases in the last 30 days', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _AmazonSmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF9900)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

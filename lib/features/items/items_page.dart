import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../categories/category_data_store.dart';

class ItemsPage extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const ItemsPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final CategoryDataStore _dataStore = CategoryDataStore();
  CategoryData? _category;

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
    _category = _dataStore.findCategory(widget.categoryName);
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month, 1);
      _toDate = now;
    });
  }

  List<CategoryItem> get _items => _category?.items ?? [];

  void _addItem(CategoryItem item) {
    setState(() {
      _category?.addItem(item);
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _category?.removeItem(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: GoogleFonts.inter(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDateSelectors(),
            const SizedBox(height: 30),
            _buildBarChart(),
            const SizedBox(height: 30),
            _buildItemsList(),
            const SizedBox(height: 20),
            _buildAddButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        SizedBox(width: 160, child: _buildSimpleDateField(label: 'From', date: _fromDate, onTap: () => _selectFromDate())),
        const Spacer(),
        SizedBox(width: 160, child: _buildSimpleDateField(label: 'To', date: _toDate, onTap: () => _selectToDate())),
      ],
    );
  }

  Widget _buildSimpleDateField({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1687F0).withValues(alpha: 0.3), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF1687F0).withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF1687F0), size: 16),
            const SizedBox(width: 8),
            Text('$label: ${date != null ? '${date.day}/${date.month}' : 'Select'}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Sort items by total price (highest first) for chart display
    final sortedItems = List<CategoryItem>.from(_items)
      ..sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
    
    final chartData = sortedItems.isEmpty
        ? [{'item': 'No Data', 'amount': 1.0}]
        : sortedItems.map((item) => {'item': item.name, 'amount': item.totalPrice}).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: CustomPaint(size: const Size(double.infinity, 200), painter: BarChartPainter(chartData)),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No items yet', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[400])),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_items.length, (index) {
        final item = _items[index];
        return _buildItemCard(item, index);
      }),
    );
  }

  Widget _buildItemCard(CategoryItem item, int index) {
    return GestureDetector(
      onLongPress: () => _showDeleteItemDialog(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF42A5F5).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(widget.categoryIcon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('${item.date.day}/${item.date.month}/${item.date.year}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('EGP ${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${item.quantity} x ${item.unitPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showDeleteItemDialog(index),
              child: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.8), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteItemDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Item', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Delete "${_items[index].name}"?', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () {
              _deleteItem(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: GestureDetector(
        onTap: () => _showAddOptions(),
        child: Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: const Color(0xFF42A5F5).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
              const BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(0, 0), spreadRadius: 2),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Add Item', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            _buildOptionTile(Icons.edit, 'Manual', 'Enter item details manually', () {
              Navigator.pop(context);
              _showManualAddDialog();
            }),
            _buildOptionTile(Icons.mic, 'Voice', 'Add item using voice', () {
              Navigator.pop(context);
              _showVoiceInputDialog();
            }),
            _buildOptionTile(Icons.document_scanner, 'OCR', 'Scan receipt or document', () {
              Navigator.pop(context);
              _showOCROptionsDialog();
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showVoiceInputDialog() {
    bool isRecording = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Voice Input', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600))),
                  ],
                ),
                const SizedBox(height: 32),
                // Mic animation container
                GestureDetector(
                  onTap: () {
                    setDialogState(() => isRecording = !isRecording);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isRecording 
                          ? [const Color(0xFFE53935), const Color(0xFFD32F2F)]
                          : [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? const Color(0xFFE53935) : const Color(0xFF42A5F5)).withValues(alpha: 0.4),
                          blurRadius: isRecording ? 20 : 12,
                          spreadRadius: isRecording ? 4 : 0,
                        ),
                      ],
                    ),
                    child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isRecording ? 'Recording...' : 'Tap to start recording',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add voice item (simulated)
                      _addItem(CategoryItem(
                        name: 'Voice Item',
                        quantity: 1,
                        unitPrice: 50,
                        date: DateTime.now(),
                        source: 'voice',
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Added successfully!', style: GoogleFonts.inter(color: Colors.white)),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text('Save', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOCROptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Scan Receipt', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 24),
              Text('Choose image source', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _processOCR('camera');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 12),
                            Text('Camera', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _processOCR('gallery');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 12),
                            Text('Gallery', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processOCR(String source) {
    // Simulated OCR processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $source for OCR...', style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Add OCR item (simulated)
    Future.delayed(const Duration(seconds: 1), () {
      _addItem(CategoryItem(
        name: 'OCR Item',
        quantity: 1,
        unitPrice: 100,
        date: DateTime.now(),
        source: 'ocr',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Added successfully!', style: GoogleFonts.inter(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0xFF1976D2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showManualAddDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Add Item', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Item Name', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Pizza, Coffee...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date selector
                  Text('Date', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '1',
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unit Price (EGP)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final quantity = int.tryParse(quantityController.text) ?? 1;
                        final price = double.tryParse(priceController.text) ?? 0;

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter item name', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: Colors.red));
                          return;
                        }
                        if (price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid price', style: GoogleFonts.inter(color: Colors.white)), backgroundColor: Colors.red));
                          return;
                        }

                        _addItem(CategoryItem(name: name, quantity: quantity, unitPrice: price, date: selectedDate, source: 'manual'));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Save', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(context: context, initialDate: _fromDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) setState(() => _fromDate = picked);
  }

  Future<void> _selectToDate() async {
    final picked = await showDatePicker(context: context, initialDate: _toDate ?? DateTime.now(), firstDate: _fromDate ?? DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) setState(() => _toDate = picked);
  }
}

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxAmount = data.map((e) => e['amount'] as double).reduce(math.max);
    // Thin bars - fixed width of 16, with dynamic spacing
    const double barWidth = 16;
    final totalBarsWidth = data.length * barWidth;
    final availableSpace = size.width - 60;
    final spacing = data.length > 1 ? (availableSpace - totalBarsWidth) / (data.length - 1) : 0.0;
    final startX = (size.width - (totalBarsWidth + spacing * (data.length - 1))) / 2;

    for (int i = 0; i < data.length; i++) {
      final amount = data[i]['amount'] as double;
      final barHeight = (amount / maxAmount) * (size.height - 50);
      final x = startX + i * (barWidth + spacing);
      final y = size.height - barHeight - 30;

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, barHeight), const Radius.circular(4)), paint);

      // Amount label on top
      final amtPainter = TextPainter(
        text: TextSpan(text: amount.toInt().toString(), style: const TextStyle(color: Color(0xFF1976D2), fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      amtPainter.layout();
      amtPainter.paint(canvas, Offset(x + barWidth / 2 - amtPainter.width / 2, y - 16));

      // Item name at bottom
      final itemName = data[i]['item'] as String;
      final namePainter = TextPainter(
        text: TextSpan(text: itemName.length > 5 ? '${itemName.substring(0, 5)}.' : itemName, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(canvas, Offset(x + barWidth / 2 - namePainter.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

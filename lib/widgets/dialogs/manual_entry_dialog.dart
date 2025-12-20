import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Manual Entry Dialog - Small dialog for adding expenses manually
/// Contains: Title, Unit Price, Quantity, Date (Category is pre-selected)
/// Total Amount = Unit Price × Quantity (calculated automatically)
class ManualEntryDialog extends StatefulWidget {
  final String? initialCategory;

  const ManualEntryDialog({super.key, this.initialCategory});

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  DateTime _selectedDate = DateTime.now();

  // Calculate total amount automatically
  double get _totalAmount {
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    return unitPrice * quantity;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Expense',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF003566),
                            ),
                          ),
                          if (widget.initialCategory != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.initialCategory!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Field
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'e.g., Coffee, Lunch, Medicine',
                  icon: Icons.title_rounded,
                  validator: (v) => v?.isEmpty ?? true ? 'Enter a title' : null,
                ),
                const SizedBox(height: 16),

                // Unit Price Field
                _buildTextField(
                  controller: _unitPriceController,
                  label: 'Unit Price (EGP)',
                  hint: '0.00',
                  icon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => setState(() {}), // Refresh total
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Enter price';
                    if (double.tryParse(v!) == null) return 'Invalid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantity Field
                _buildTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: '1',
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}), // Refresh total
                ),
                const SizedBox(height: 16),

                // Total Amount (Calculated)
                _buildTotalAmount(),
                const SizedBox(height: 16),

                // Date Field
                _buildDateField(),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003566),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Expense',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF003566), size: 20),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003566).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF003566).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF003566),
            ),
          ),
          Text(
            'EGP ${_totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF003566),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF003566),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final expense = {
        'title': _titleController.text,
        'amount': _totalAmount, // Total = Unit Price × Quantity
        'quantity': int.tryParse(_quantityController.text) ?? 1,
        'unitPrice': double.tryParse(_unitPriceController.text) ?? 0,
        'date': _selectedDate,
        'category': widget.initialCategory ?? 'Other',
      };
      Navigator.pop(context, expense);
    }
  }
}

/// Show the Manual Entry Dialog
Future<Map<String, dynamic>?> showManualEntryDialog(
  BuildContext context, {
  String? initialCategory,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => ManualEntryDialog(initialCategory: initialCategory),
  );
}

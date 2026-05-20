import 'package:flutter/material.dart';

const Color _kPrimary = Color(0xFF765A00);
const Color _kPrimaryContainer = Color(0xFFE3BC58);
const Color _kOnPrimaryContainer = Color(0xFF634B00);
const Color _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color _kSurfaceContainer = Color(0xFFF5EDE1);
const Color _kOnSurface = Color(0xFF1F1B14);
const Color _kOnSurfaceVariant = Color(0xFF4D4637);
const Color _kOutline = Color(0xFF7F7665);

class EditablePriceCard extends StatefulWidget {
  const EditablePriceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.unit,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final double price;
  final String unit;
  final Future<bool> Function(double) onSave;

  @override
  State<EditablePriceCard> createState() => _EditablePriceCardState();
}

class _EditablePriceCardState extends State<EditablePriceCard> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.price.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(EditablePriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.price != widget.price) {
      _controller.text = widget.price.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(double p) => p.toStringAsFixed(2).replaceAll('.', ',');

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _controller.text = widget.price.toStringAsFixed(2);
      }
    });
  }

  Future<void> _savePrice() async {
    final raw = _controller.text.replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null) return;

    setState(() => _isSaving = true);
    final success = await widget.onSave(value);
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimaryContainer, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: icon | title+subtitle | badge+edit ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: _kOnPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _kOnSurface,
                      ),
                    ),
                    Text(
                      widget.subtitle.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _kOnSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge + edit button stacked on the right
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kPrimaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULÄR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kOnPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _isEditing ? null : _toggleEdit,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kSurfaceContainer,
                      ),
                      child: Icon(
                        _isEditing
                            ? Icons.edit_off_outlined
                            : Icons.edit_outlined,
                        color: _kPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Price display or edit input ──
          if (!_isEditing) _buildPriceDisplay() else _buildEditInput(),
        ],
      ),
    );
  }

  Widget _buildPriceDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatPrice(widget.price)} €',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          widget.unit,
          style: const TextStyle(fontSize: 11, color: _kOnSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildEditInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: _kPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _kPrimary, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _kPrimary, width: 2),
                ),
                contentPadding: EdgeInsets.only(bottom: 4, right: 28),
                hintText: '0,00',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                '€',
                style: TextStyle(
                  color: _kPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _toggleEdit,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kOutline),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(
                    color: _kOnSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Speichern',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

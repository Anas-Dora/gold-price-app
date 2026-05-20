import 'package:flutter/material.dart';

const Color _kOutlineVariant = Color(0xFFD0C5B1);
const Color _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color _kSurfaceContainer = Color(0xFFF5EDE1);
const Color _kOnSurface = Color(0xFF1F1B14);
const Color _kOnSurfaceVariant = Color(0xFF4D4637);
const Color _kError = Color(0xFFBA1A1A);
const Color _kGreen = Color(0xFF386A1F);

class PriceCard extends StatelessWidget {
  const PriceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.unit,
    required this.icon,
    this.changePercent,
    this.priceBold = false,
  });

  final String title;
  final String subtitle;
  final double price;
  final String unit;
  final IconData icon;

  /// When set, shows a coloured change indicator below the price.
  final double? changePercent;

  /// Makes the price text bold (used for Unze card).
  final bool priceBold;

  static String formatPrice(double p) =>
      p.toStringAsFixed(2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kOutlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: icon + title + subtitle
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kSurfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kOutlineVariant),
                ),
                child: Icon(icon, color: _kOnSurfaceVariant, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _kOnSurface,
                    ),
                  ),
                  Text(
                    subtitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _kOnSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Right: price + unit / change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatPrice(price)} €',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: priceBold ? FontWeight.w700 : FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
              if (changePercent != null)
                _ChangeChip(changePercent: changePercent!)
              else
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kOnSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.changePercent});

  final double changePercent;

  @override
  Widget build(BuildContext context) {
    final isUp = changePercent >= 0;
    final color = isUp ? _kGreen : _kError;
    final sign = isUp ? '+' : '';
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          '$sign${changePercent.toStringAsFixed(2).replaceAll('.', ',')} %',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

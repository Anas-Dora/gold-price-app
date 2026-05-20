import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gold_price_viewmodel.dart';
import 'widgets/price_card.dart';
import 'widgets/editable_price_card.dart';

const Color _kPrimary = Color(0xFF765A00);
const Color _kBackground = Color(0xFFFFF8F1);
const Color _kSurface = Color(0xFFFFF8F1);
const Color _kOnSurface = Color(0xFF1F1B14);
const Color _kOnSurfaceVariant = Color(0xFF4D4637);
const Color _kOutlineVariant = Color(0xFFD0C5B1);
const Color _kError = Color(0xFFBA1A1A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoldPriceViewModel>().loadPrices();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _spinController.forward(from: 0.0);
    await context.read<GoldPriceViewModel>().refresh();
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.$y, $h:$min Uhr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kOutlineVariant),
        ),
        title: const Text(
          'Durrah Juwelier',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: RotationTransition(
              turns: _spinAnimation,
              child: IconButton(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh, color: _kPrimary),
                style: IconButton.styleFrom(shape: const CircleBorder()),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GoldPriceViewModel>(
        builder: (context, vm, _) {
          // Initial loading — no data yet
          if (vm.state == ViewState.loading && !vm.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            );
          }

          // Error — no data yet
          if (vm.state == ViewState.error && !vm.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: _kError, size: 52),
                    const SizedBox(height: 16),
                    const Text(
                      'Fehler beim Laden',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _kOnSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.error ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Nochmal versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Data available
          return RefreshIndicator(
            color: _kPrimary,
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
              children: [
                _LiveHeader(
                  lastUpdated: vm.lastUpdated,
                  formatDateTime: _formatDateTime,
                ),
                const SizedBox(height: 24),
                if (vm.hasData) ..._buildPriceCards(vm),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPriceCards(GoldPriceViewModel vm) {
    final spot = vm.spotRate!;
    final firebase = vm.goldData!;
    const gap = SizedBox(height: 12);

    return [
      // ── 24 Karat — live from API ──────────────────────────────
      PriceCard(
        title: '24 Karat',
        subtitle: '999.9',
        price: spot.price24k,
        unit: 'Pro Gramm',
        icon: Icons.pentagon_outlined,
      ),
      gap,
      // ── 22 Karat — live from API ──────────────────────────────
      PriceCard(
        title: '22 Karat',
        subtitle: '916',
        price: spot.price22k,
        unit: 'Pro Gramm',
        icon: Icons.hexagon_outlined,
      ),
      gap,
      // ── 21 Karat — POPULÄR, stored & editable in Firebase ─────
      EditablePriceCard(
        title: '21 Karat',
        subtitle: '875',
        price: firebase.gold21k,
        unit: 'Personalisierter Marktpreis',
        onSave: (value) => vm.saveGold21k(value),
      ),
      gap,
      // ── 18 Karat — live from API ──────────────────────────────
      PriceCard(
        title: '18 Karat',
        subtitle: '750',
        price: spot.price18k,
        unit: 'Pro Gramm',
        icon: Icons.crop_square_outlined,
      ),
      gap,
      // ── Unze (1 oz) — live from API, with change % ───────────
      PriceCard(
        title: 'Unze (1 oz)',
        subtitle: '31,1 g',
        price: spot.price,
        unit: 'Pro Unze',
        icon: Icons.scale_outlined,
        changePercent: spot.changePercent,
        priceBold: true,
      ),
    ];
  }
}

// ── Live header widget ──────────────────────────────────────────────────────

class _LiveHeader extends StatefulWidget {
  const _LiveHeader({required this.lastUpdated, required this.formatDateTime});

  final DateTime lastUpdated;
  final String Function(DateTime) formatDateTime;

  @override
  State<_LiveHeader> createState() => _LiveHeaderState();
}

class _LiveHeaderState extends State<_LiveHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.25, end: 1.0).animate(_pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Left: label + headline
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE MARKTBERICHT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _kOnSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aktuelle Kurse',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
            ],
          ),
        ),
        // Right: LIVE badge + date
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _kPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              widget.formatDateTime(widget.lastUpdated),
              style: const TextStyle(fontSize: 11, color: _kOnSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

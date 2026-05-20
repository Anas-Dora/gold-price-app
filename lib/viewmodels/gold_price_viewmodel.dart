import 'package:flutter/foundation.dart';
import '../models/gold_data.dart';
import '../models/spot_rate.dart';
import '../services/firestore_service.dart';
import '../services/metals_api_service.dart';

enum ViewState { initial, loading, success, error }

class GoldPriceViewModel extends ChangeNotifier {
  GoldPriceViewModel()
    : _firestore = FirestoreService(),
      _api = MetalsApiService();

  final FirestoreService _firestore;
  final MetalsApiService _api;

  ViewState _state = ViewState.initial;
  SpotRate? _spotRate;
  GoldData? _goldData; // Firebase: only gold21k
  String? _error;
  DateTime _lastUpdated = DateTime.now();

  ViewState get state => _state;
  SpotRate? get spotRate => _spotRate;
  GoldData? get goldData => _goldData;
  String? get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  /// True when we have enough data to render the screen.
  bool get hasData => _spotRate != null && _goldData != null;

  Future<void> loadPrices() async {
    _state = ViewState.loading;
    notifyListeners();
    try {
      // Fetch API and Firebase concurrently
      final results = await Future.wait([
        _api.fetchSpotPrice(),
        _firestore.fetchGold21k(),
      ]);
      _spotRate = results[0] as SpotRate;
      _goldData = results[1] as GoldData;
      _lastUpdated = DateTime.now();
      _state = ViewState.success;
    } catch (e) {
      _error = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadPrices();
    try {
      await _firestore.logRefreshPressed();
    } catch (_) {}
  }

  Future<bool> saveGold21k(double value) async {
    try {
      await _firestore.updateGold21k(value);
      _goldData = _goldData?.copyWith(gold21k: value);
      _lastUpdated = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

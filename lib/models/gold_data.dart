/// Firebase-stored data. Only the 21 Karat price is managed here;
/// all other karat prices are calculated live from the metals.dev API.
class GoldData {
  final double gold21k;

  const GoldData({required this.gold21k});

  factory GoldData.fromMap(Map<String, dynamic> map) {
    return GoldData(gold21k: (map['gold_21k'] as num?)?.toDouble() ?? 0.0);
  }

  GoldData copyWith({double? gold21k}) =>
      GoldData(gold21k: gold21k ?? this.gold21k);
}

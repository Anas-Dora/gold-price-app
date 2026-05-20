class SpotRate {
  final double price;
  final double high;
  final double low;
  final double change;
  final double changePercent;

  const SpotRate({
    required this.price,
    required this.high,
    required this.low,
    required this.change,
    required this.changePercent,
  });

  factory SpotRate.fromJson(Map<String, dynamic> json) {
    final rate = json['rate'] as Map<String, dynamic>;
    double d(String k) => (rate[k] as num).toDouble();
    return SpotRate(
      price: d('price'),
      high: d('high'),
      low: d('low'),
      change: d('change'),
      changePercent: d('change_percent'),
    );
  }

  // Troy ounce → grams conversion
  static const double _gramsPerOz = 31.1035;

  double get pricePerGram => price / _gramsPerOz;
  double get price24k => pricePerGram;
  double get price22k => pricePerGram * (22 / 24);
  double get price18k => pricePerGram * (18 / 24);

  bool get isUp => changePercent >= 0;
}

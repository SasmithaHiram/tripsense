class AiRecommendation {
  final String title;
  final String? location;
  final String? category;
  final double? estimatedCost;
  final double? estimatedDistanceKm;
  final double? durationHours;
  final double? score;

  AiRecommendation({
    required this.title,
    this.location,
    this.category,
    this.estimatedCost,
    this.estimatedDistanceKm,
    this.durationHours,
    this.score,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return AiRecommendation(
      title: (json['title'] ?? '').toString(),
      location: json['location']?.toString(),
      category: json['category']?.toString(),
      estimatedCost: _toDouble(json['estimatedCost']),
      estimatedDistanceKm: _toDouble(json['estimatedDistanceKm']),
      durationHours: _toDouble(json['durationHours']),
      score: _toDouble(json['score']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    if (location != null) 'location': location,
    if (category != null) 'category': category,
    if (estimatedCost != null) 'estimatedCost': estimatedCost,
    if (estimatedDistanceKm != null) 'estimatedDistanceKm': estimatedDistanceKm,
    if (durationHours != null) 'durationHours': durationHours,
    if (score != null) 'score': score,
  };
}

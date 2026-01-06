class TripFilters {
  final Set<String> categories;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxDistanceKm;
  final double? maxBudget;

  TripFilters({
    this.categories = const {},
    this.location,
    this.startDate,
    this.endDate,
    this.maxDistanceKm,
    this.maxBudget,
  });

  TripFilters copyWith({
    Set<String>? categories,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? maxDistanceKm,
    double? maxBudget,
  }) {
    return TripFilters(
      categories: categories ?? this.categories,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      maxBudget: maxBudget ?? this.maxBudget,
    );
  }
}

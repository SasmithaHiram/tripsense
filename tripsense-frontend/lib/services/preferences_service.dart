import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String categoriesKey = 'preferred_categories';
  static const String tripLocationKey = 'trip_location';
  static const String tripStartDateKey = 'trip_start_date';
  static const String tripEndDateKey = 'trip_end_date';
  static const String tripMaxDistanceKey = 'trip_max_distance_km';
  static const String tripMaxBudgetKey = 'trip_max_budget';

  Future<Set<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(categoriesKey) ?? const [];
    return list.toSet();
  }

  Future<void> saveCategories(Set<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(categoriesKey, categories.toList());
  }

  Future<void> clearCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(categoriesKey);
  }

  Future<void> saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tripLocationKey, location);
  }

  Future<String?> loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tripLocationKey);
  }

  Future<void> saveDates({
    required DateTime start,
    required DateTime end,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tripStartDateKey, start.toIso8601String());
    await prefs.setString(tripEndDateKey, end.toIso8601String());
  }

  Future<(DateTime?, DateTime?)> loadDates() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(tripStartDateKey);
    final e = prefs.getString(tripEndDateKey);
    return (
      s != null ? DateTime.tryParse(s) : null,
      e != null ? DateTime.tryParse(e) : null,
    );
  }

  Future<void> saveConstraints({
    required int maxDistanceKm,
    required double maxBudget,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(tripMaxDistanceKey, maxDistanceKm);
    await prefs.setDouble(tripMaxBudgetKey, maxBudget);
  }

  Future<(int?, double?)> loadConstraints() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      prefs.getInt(tripMaxDistanceKey),
      prefs.getDouble(tripMaxBudgetKey),
    );
  }
}

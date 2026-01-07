import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_service.dart';
import '../services/preferences_api_service.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _prefs = PreferencesService();
  final _prefsApi = PreferencesApiService();
  bool _loading = true;
  Set<String> _categories = {};
  String? _location;
  DateTime? _start;
  DateTime? _end;
  int? _maxDistance;
  double? _maxBudget;
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _prefs.loadCategories();
    final loc = await _prefs.loadLocation();
    final (s, e) = await _prefs.loadDates();
    final (d, b) = await _prefs.loadConstraints();

    // Fetch suggestions via /preferences/user/{id}
    List<String> suggestions = const [];
    try {
      final sp = await SharedPreferences.getInstance();
      final userId = sp.getInt('user_id');
      if (userId != null) {
        suggestions = await _prefsApi.getUserSuggestionTitles(userId);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _location = loc;
      _start = s;
      _end = e;
      _maxDistance = d;
      _maxBudget = b;
      _suggestions = suggestions;
      _loading = false;
    });
  }

  String _dateText(DateTime? d) {
    if (d == null) return 'Not set';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TripSense Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Edit Preferences',
            onPressed: () => Navigator.pushNamed(context, '/preferences'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Your trip setup',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Categories'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories
                                .map((c) => Chip(label: Text(c)))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          const Text('Location'),
                          const SizedBox(height: 4),
                          Text(_location ?? 'Not set'),
                          const SizedBox(height: 12),
                          const Text('Dates'),
                          const SizedBox(height: 4),
                          Text('${_dateText(_start)} → ${_dateText(_end)}'),
                          const SizedBox(height: 12),
                          const Text('Constraints'),
                          const SizedBox(height: 4),
                          Text('Max distance: ${_maxDistance ?? '-'} km'),
                          Text('Max budget: ${_maxBudget ?? '-'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Suggestions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_suggestions.isEmpty)
                    const Text('No suggestions yet – try updating preferences.')
                  else
                    Column(
                      children: _suggestions
                          .map(
                            (s) => ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(s),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () async {
                        setState(() => _loading = true);
                        await _load();
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Explore suggestions'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

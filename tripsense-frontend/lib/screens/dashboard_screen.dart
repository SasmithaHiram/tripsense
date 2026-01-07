import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_service.dart';
import '../services/preferences_api_service.dart';
import '../models/ai_recommendation.dart';
import '../widgets/recommendations_insights.dart';
import '../services/user_api_service.dart';
import '../utils/jwt_utils.dart';

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
  List<AiRecommendation> _suggestions = const [];
  String? _selectedCategory;
  int? _selectedTopIndex;
  int _visibleCount = 10;

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
    List<AiRecommendation> suggestions = const [];
    try {
      final sp = await SharedPreferences.getInstance();
      final userId = sp.getInt('user_id');
      if (userId != null) {
        suggestions = await _prefsApi.getUserRecommendations(userId);
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

  List<AiRecommendation> _filteredSuggestions() {
    List<AiRecommendation> items = List.of(_suggestions);
    if (_selectedCategory != null) {
      items = items
          .where((r) => r.category != null && r.category == _selectedCategory)
          .toList();
    }
    if (_selectedTopIndex != null) {
      final sorted = List<AiRecommendation>.from(_suggestions)
        ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
      if (_selectedTopIndex! >= 0 && _selectedTopIndex! < sorted.length) {
        final target = sorted[_selectedTopIndex!];
        items = items.where((r) => r.title == target.title).toList();
      }
    }
    return items;
  }

  Future<List<AiRecommendation>> _fetchWithRetry(int userId) async {
    final delays = [0, 500, 1500];
    for (final ms in delays) {
      try {
        if (ms > 0) {
          await Future.delayed(Duration(milliseconds: ms));
        }
        final results = await _prefsApi.getUserRecommendations(userId);
        return results;
      } catch (_) {
        // try next
      }
    }
    // Fallback to cached data
    try {
      final sp = await SharedPreferences.getInstance();
      final cached = sp.getString('cached_recommendations');
      if (cached != null && cached.isNotEmpty) {
        final raw = jsonDecode(cached) as List<dynamic>;
        return raw
            .map((e) => AiRecommendation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    throw Exception('Failed to fetch recommendations');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSetup =
        _categories.isNotEmpty ||
        _location != null ||
        _start != null ||
        _end != null ||
        _maxDistance != null ||
        _maxBudget != null;
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
                  if (hasSetup) ...[
                    const Text(
                      'Your trip setup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
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
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Get started',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You haven\'t set up your preferences yet. Add them to tailor your trip suggestions.',
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/preferences',
                                ),
                                icon: const Icon(Icons.tune),
                                label: const Text('Set up preferences'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Suggestions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_filteredSuggestions().isEmpty)
                    const Text('No suggestions yet – try updating preferences.')
                  else
                    Column(
                      children: _filteredSuggestions()
                          .take(_visibleCount)
                          .map(
                            (r) => ListTile(
                              leading: const Icon(Icons.explore_outlined),
                              title: Text(r.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (r.location != null) Text(r.location!),
                                  Text(
                                    [
                                      if (r.category != null)
                                        'Category: ${r.category}',
                                      if (r.estimatedCost != null)
                                        'Cost: ${r.estimatedCost!.toStringAsFixed(0)}',
                                      if (r.estimatedDistanceKm != null)
                                        '${r.estimatedDistanceKm!.toStringAsFixed(0)} km',
                                      if (r.durationHours != null)
                                        '${r.durationHours!.toStringAsFixed(1)} h',
                                    ].join(' • '),
                                  ),
                                ],
                              ),
                              trailing: (r.score != null)
                                  ? Chip(
                                      label: Text(
                                        'Score ${r.score!.toStringAsFixed(1)}',
                                      ),
                                    )
                                  : null,
                            ),
                          )
                          .toList(),
                    ),
                  if (_filteredSuggestions().length > _visibleCount)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _visibleCount += 10),
                          child: const Text('Load more'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  RecommendationsInsights(
                    items: _suggestions,
                    onSelectCategory: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                        _visibleCount = 10;
                      });
                    },
                    onSelectTopIndex: (idx) {
                      setState(() {
                        _selectedTopIndex = idx;
                        _visibleCount = 10;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () async {
                        setState(() => _loading = true);
                        try {
                          final sp = await SharedPreferences.getInstance();
                          int? userId = sp.getInt('user_id');

                          if (userId == null) {
                            final token = sp.getString('auth_token');
                            if (token != null && token.isNotEmpty) {
                              final decodedId = JwtUtils.extractUserId(token);
                              if (decodedId != null) {
                                userId = decodedId;
                                await sp.setInt('user_id', userId);
                              }
                            }
                          }

                          if (userId == null) {
                            try {
                              final me = await UserApiService().getMe();
                              final id = me['id'] as int?;
                              if (id != null) {
                                userId = id;
                                await sp.setInt('user_id', userId);
                              }
                            } catch (_) {}
                          }

                          if (userId == null) {
                            throw Exception('User id not available');
                          }

                          final results = await _fetchWithRetry(userId);
                          if (!mounted) return;
                          setState(() {
                            _suggestions = results;
                            _loading = false;
                            _visibleCount = 10;
                            _selectedCategory = null;
                            _selectedTopIndex = null;
                          });
                          // Cache results
                          try {
                            final raw = results.map((e) => e.toJson()).toList();
                            await sp.setString(
                              'cached_recommendations',
                              jsonEncode(raw),
                            );
                          } catch (_) {}
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to fetch suggestions: $e'),
                            ),
                          );
                        }
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

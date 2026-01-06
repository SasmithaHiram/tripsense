import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class PreferencesScreen extends StatefulWidget {
  static const routeName = '/preferences';
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _prefsService = PreferencesService();
  final List<String> _allCategories = const [
    'Adventure',
    'Beach',
    'Cultural',
    'Leisure',
    'Nature',
    'Romantic',
    'Wildlife',
    'Historical',
  ];

  final Set<String> _selected = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _prefsService.loadCategories();
    if (!mounted) return;
    setState(() {
      _selected
        ..clear()
        ..addAll(saved);
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }
    await _prefsService.saveCategories(_selected);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
  }

  Future<void> _skip() async {
    // Optional: clear saved categories to represent skipping
    await _prefsService.clearCategories();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Skipped for now')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Preferences')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Choose your travel interests',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allCategories.map((c) {
                        final selected = _selected.contains(c);
                        return FilterChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                _selected.add(c);
                              } else {
                                _selected.remove(c);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skip,
                            child: const Text('Skip for now'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              if (_selected.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select at least one category',
                                    ),
                                  ),
                                );
                                return;
                              }
                              await _prefsService.saveCategories(_selected);
                              if (!mounted) return;
                              Navigator.pushNamed(context, '/location');
                            },
                            child: const Text('Next'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/preferences_api_service.dart';

class ConstraintsScreen extends StatefulWidget {
  static const routeName = '/constraints';
  const ConstraintsScreen({super.key});

  @override
  State<ConstraintsScreen> createState() => _ConstraintsScreenState();
}

class _ConstraintsScreenState extends State<ConstraintsScreen> {
  final _prefs = PreferencesService();
  final _api = PreferencesApiService();
  final _formKey = GlobalKey<FormState>();
  final _distanceCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final (d, b) = await _prefs.loadConstraints();
    if (!mounted) return;
    setState(() {
      if (d != null) _distanceCtrl.text = d.toString();
      if (b != null) _budgetCtrl.text = b.toStringAsFixed(0);
      _loading = false;
    });
  }

  String? _requiredNum(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    final distance = int.tryParse(_distanceCtrl.text.trim());
    final budget = double.tryParse(_budgetCtrl.text.trim());
    if (distance == null || distance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid max distance in km')),
      );
      return;
    }
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid max budget')));
      return;
    }
    setState(() => _submitting = true);
    try {
      // Persist constraints locally first
      await _prefs.saveConstraints(maxDistanceKm: distance, maxBudget: budget);

      // Load all pieces to build request
      final categories = await _prefs.loadCategories();
      final loc = await _prefs.loadLocation();
      final (s, e) = await _prefs.loadDates();

      if (categories.isEmpty || loc == null || s == null || e == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all previous steps')),
        );
        return;
      }

      await _api.submitPreferences(
        categories: categories,
        locations: [loc],
        startDate: s,
        endDate: e,
        maxDistanceKm: distance,
        maxBudget: budget,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences submitted to backend')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distance & Budget')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _distanceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Max distance (km)',
                        prefixIcon: Icon(Icons.social_distance),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _requiredNum,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _budgetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Max budget',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _requiredNum,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _submitting ? null : _finish,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Finish'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

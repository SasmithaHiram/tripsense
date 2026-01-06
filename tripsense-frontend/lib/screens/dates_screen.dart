import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class DatesScreen extends StatefulWidget {
  static const routeName = '/dates';
  const DatesScreen({super.key});

  @override
  State<DatesScreen> createState() => _DatesScreenState();
}

class _DatesScreenState extends State<DatesScreen> {
  final _prefs = PreferencesService();
  DateTime? _start;
  DateTime? _end;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final (s, e) = await _prefs.loadDates();
    if (!mounted) return;
    setState(() {
      _start = s;
      _end = e;
      _loading = false;
    });
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      setState(() {
        _start = DateTime(picked.year, picked.month, picked.day);
        if (_end != null && _end!.isBefore(_start!)) {
          _end = _start;
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    final base = _start ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? base,
      firstDate: base,
      lastDate: DateTime(base.year + 3),
    );
    if (picked != null) {
      setState(() {
        _end = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _next() async {
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    await _prefs.saveDates(start: _start!, end: _end!);
    if (!mounted) return;
    Navigator.pushNamed(context, '/constraints');
  }

  @override
  Widget build(BuildContext context) {
    final dateText = (DateTime? d) => d == null
        ? 'Not selected'
        : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Select Dates')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start date'),
                    subtitle: Text(dateText(_start)),
                    trailing: const Icon(Icons.date_range),
                    onTap: _pickStart,
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End date'),
                    subtitle: Text(dateText(_end)),
                    trailing: const Icon(Icons.date_range),
                    onTap: _pickEnd,
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _next,
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
